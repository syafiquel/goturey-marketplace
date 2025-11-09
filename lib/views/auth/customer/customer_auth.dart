import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cooler_alerts/cooler_alerts.dart';
import 'package:flutter/material.dart';
import '../../../constants/color.dart';
import '../../../constants/enums/account_type.dart';
import '../../../constants/enums/fields.dart';
import '../../../constants/enums/status.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/route_manager.dart';
import '../../../helpers/auth_error_formatter.dart';
import '../../../helpers/shared_prefs.dart';
import '../../../models/auth_result.dart';
import '../../../resources/assets_manager.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/msg_snackbar.dart';
import '../../widgets/kcool_alert.dart';

import '../../../helpers/image_picker.dart';

class CustomerAuthScreen extends StatefulWidget {
  const CustomerAuthScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomerAuthScreen> createState() => _CustomerAuthScreenState();
}

class _CustomerAuthScreenState extends State<CustomerAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  var obscure = true; // password obscure value
  var isLogin = true;
  File? profileImage;
  var isLoading = false;
  AccountType _accountType = AccountType.customer;
  final firebase = FirebaseFirestore.instance;
  final AuthController _authController = AuthController();

  // toggle password obscure
  _togglePasswordObscure() {
    setState(() {
      obscure = !obscure;
    });
  }

  // Helper function to check if an email exists in customer or vendor collections
  Future<Map<String, bool>> _checkEmailExistence(String email) async {
    bool customerExists = false;
    bool vendorExists = false;

    // Check in customers collection
    QuerySnapshot customerQuery = await firebase
        .collection('customers')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (customerQuery.docs.isNotEmpty) {
      customerExists = true;
    }

    // Check in vendors collection
    QuerySnapshot vendorQuery = await firebase
        .collection('vendors')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (vendorQuery.docs.isNotEmpty) {
      vendorExists = true;
    }

    return {'customer': customerExists, 'vendor': vendorExists};
  }

  // get context
  get ctxt {
    return context;
  }

  // custom textfield for all form fields
  Widget kTextField(
    TextEditingController controller,
    String hint,
    String label,
    Field field,
    bool obscureText,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: field == Field.email
          ? TextInputType.emailAddress
          : field == Field.phone
              ? TextInputType.phone
              : TextInputType.text,
      textInputAction:
          field == Field.password ? TextInputAction.done : TextInputAction.next,
      autofocus: field == Field.email ? true : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: accentColor),
        suffixIcon: field == Field.password
            ? _passwordController.text.isNotEmpty
                ? IconButton(
                    onPressed: () => _togglePasswordObscure(),
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: accentColor,
                    ),
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
        hintText: hint,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 2,
            color: accentColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        ),
      ),
      validator: (value) {
        switch (field) {
          case Field.email:
            if (!value!.contains('@')) {
              return 'Email is not valid!';
            }
            if (value.isEmpty) {
              return 'Email can not be empty';
            }
            break;
          case Field.fullname:
            if (value!.isEmpty || value.length < 3) {
              return 'Fullname is not valid';
            }
            break;
          case Field.phone:
            if (value!.isEmpty || value.length < 10) {
              return 'Phone number is not valid';
            }
            break;
          case Field.password:
            if (value!.isEmpty || value.length < 6) {
              return 'Password needs to be valid';
            }
            break;
          default:
            return null;
        }
        return null;
      },
    );
  }

  // for selecting photo
  _selectPhoto(File image) {
    setState(() {
      profileImage = image;
    });
  }

  // loading fnc
  isLoadingFnc() async {
    setState(() {
      isLoading = true;
    });

    if (isLogin) {
      await _getAndNavigateBasedOnAccountType();
    } else {
      if (_accountType == AccountType.customer) {
        // customer account
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteManager.customerMainScreen,
          (route) => false,
        );
      } else {
        // vendor account
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteManager.vendorMainScreen,
          (route) => false,
        );
      }
    }
  }

  Future<void> _getAndNavigateBasedOnAccountType() async {
    final user = _authController.auth.currentUser;
    if (user == null) {
      // Handle case where user is not signed in (should not happen here)
      return;
    }

    final String? userEmail = user.email;
    if (userEmail == null) {
      // Handle case where user email is not available
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteManager.customerMainScreen, // Default fallback
        (route) => false,
      );
      return;
    }

    Map<String, bool> emailExistence = await _checkEmailExistence(userEmail);
    bool customerEmailExists = emailExistence['customer']!;
    bool vendorEmailExists = emailExistence['vendor']!;

    AccountType? finalAccountType;

    if (customerEmailExists && vendorEmailExists) {
      // If email exists in both, prompt user to choose
      finalAccountType = await showDialog<AccountType>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choose Account Type'),
            content: const Text('This email is associated with both a customer and a vendor account. Which one would you like to log in as?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Customer'),
                onPressed: () {
                  Navigator.of(context).pop(AccountType.customer);
                },
              ),
              TextButton(
                child: const Text('Vendor'),
                onPressed: () {
                  Navigator.of(context).pop(AccountType.vendor);
                },
              ),
            ],
          );
        },
      );

      if (finalAccountType == null) {
        // User cancelled the choice, log out or show error
        await _authController.auth.signOut(); // Sign out the user if they cancel
        completeAction(); // Reset loading state and pop any dialogs
        return;
      }
    } else if (customerEmailExists) {
      finalAccountType = AccountType.customer;
    } else if (vendorEmailExists) {
      finalAccountType = AccountType.vendor;
    } else {
      // If email not found in either (e.g., new Google sign-in, or data inconsistency)
      // Fallback to checking by UID, or default to customer
      DocumentSnapshot customerDoc = await firebase.collection('customers').doc(user.uid).get();
      if (customerDoc.exists) {
        finalAccountType = AccountType.customer;
      } else {
        DocumentSnapshot vendorDoc = await firebase.collection('vendors').doc(user.uid).get();
        if (vendorDoc.exists) {
          finalAccountType = AccountType.vendor;
        } else {
          // If neither email nor UID found, default to customer
          finalAccountType = AccountType.customer;
        }
      }
    }

    // Navigate based on the finalAccountType
    if (finalAccountType == AccountType.customer) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteManager.customerMainScreen,
        (route) => false,
      );
    } else if (finalAccountType == AccountType.vendor) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteManager.vendorMainScreen,
        (route) => false,
      );
    } else {
      // Should not happen if finalAccountType is always set
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteManager.customerMainScreen, // Default fallback
        (route) => false,
      );
    }
  }

  // called after an action is completed
  void completeAction() {
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  // handle sign in and  sign up
  _handleAuth() async {
    var valid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    if (!valid) {
      displaySnackBar(
        message: 'Form needs to be accurately filled',
        status: Status.error,
        context: context,
      );
      return null;
    }

    if (isLogin) {
      // TODO: implement sign in
      setState(() {
        isLoading = true;
      });

      AuthResult? result = await _authController.signInUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (result!.user == null) {
        kCoolAlert(
          message: result.errorMessage!,
          context: ctxt,
          alert: CoolAlertType.error,
          action: (_) => completeAction(),
        );
      } else {
        isLoadingFnc();
      }
    } else {
      // TODO: implement sign up
      // if (profileImage == null) {
      //   // profile image is empty
      //   displaySnackBar(
      //     message: 'Profile image can not be empty!',
      //     status: Status.error,
      //     context: context,
      //   );
      //   return null;
      // }

      setState(() {
        isLoading = true;
      });

      AuthResult? result = await _authController.signUpUser(
        email: _emailController.text.trim(),
        fullname: _fullnameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        accountType: _accountType,
        //profileImage: profileImage,
        //profileImage: 'https://placehold.co/400x400?text=No+Image',
      );

      if (result!.user == null) {
        kCoolAlert(
          message: result.errorMessage!,
          context: ctxt,
          alert: CoolAlertType.error,
          action: (_) => completeAction(),
        );
      } else {
        isLoadingFnc();
      }
    }
  }

// authenticate using Google
  _googleAuth() async {
    setState(() {
      isLoading = true;
    });

    try {
      AuthResult? result = await _authController.googleAuth(
        _accountType,
      );

      if (result!.user != null) {
        isLoadingFnc();
      } else {
        kCoolAlert(
          message: result.errorMessage!,
          context: ctxt,
          alert: CoolAlertType.error,
          action: (_) => completeAction(),
        );
      }
    } catch (e) {
      kCoolAlert(
        message: extractErrorMessage(e.toString()),
        context: ctxt,
        alert: CoolAlertType.error,
        action: (_) => completeAction(),
      );
    }
  }

  // navigate to forgot password screen
  _forgotPassword() {
    Navigator.of(context).pushNamed(RouteManager.customerForgotPass);
  }

  // switch authentication mode
  _switchLog() {
    setState(() {
      isLogin = !isLogin;
      _passwordController.text = "";
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _passwordController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  !isLogin
                      ? ProfileImagePicker(selectImage: _selectPhoto)
                      : Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 60,
                            child: Image.asset(AssetManager.loginImage),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      isLogin
                          ? 'Sign in to your Account'
                          : 'Signup for a new Account',
                      style: const TextStyle(
                        color: accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  !isLogin
                      ? Center(
                          child: ToggleButtons(
                            isSelected: [
                              _accountType == AccountType.customer,
                              _accountType == AccountType.vendor,
                            ],
                            onPressed: (index) {
                              setState(() {
                                _accountType = index == 0
                                    ? AccountType.customer
                                    : AccountType.vendor;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            selectedColor: Colors.white,
                            fillColor: primaryColor,
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text('Customer'),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text('Vendor'),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 20),
                  isLoading
                      ? const Center(
                          child: LoadingWidget(
                            size: 70,
                          ),
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              kTextField(
                                _emailController,
                                'doe@gmail.com',
                                'Email Address',
                                Field.email,
                                false,
                              ),
                              const SizedBox(height: 10),
                              !isLogin
                                  ? kTextField(
                                      _fullnameController,
                                      'John Doe',
                                      'Fullname',
                                      Field.fullname,
                                      false,
                                    )
                                  : const SizedBox.shrink(),
                              SizedBox(height: isLogin ? 0 : 10),
                              !isLogin
                                  ? kTextField(
                                      _phoneController,
                                      '+234-000-000-000',
                                      'Phone Number',
                                      Field.phone,
                                      false,
                                    )
                                  : const SizedBox.shrink(),
                              SizedBox(height: isLogin ? 0 : 10),
                              SizedBox(height: isLogin ? 0 : 10),
                              kTextField(
                                _passwordController,
                                '********',
                                'Password',
                                Field.password,
                                obscure,
                              ),
                              SizedBox(height: isLogin ? 30 : 10),
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(15),
                                  ),
                                  icon: Icon(
                                    isLogin
                                        ? Icons.person
                                        : Icons.person_add_alt_1,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => _handleAuth(),
                                  label: Text(
                                    isLogin
                                        ? 'Signin Account'
                                        : 'Signup Account',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                ),
                                onPressed: () => _googleAuth(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google.png',
                                      width: 20,
                                    ),
                                    const SizedBox(width: 20),
                                    Text(
                                      isLogin
                                          ? 'Signin with google'
                                          : 'Signup with google',
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () => _forgotPassword(),
                                    child: const Text(
                                      'Forgot Password',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _switchLog(),
                                    child: Text(
                                      isLogin
                                          ? 'New here? Create Account'
                                          : 'Already a user? Sign in',
                                      style: const TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
