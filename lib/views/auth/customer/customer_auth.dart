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
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          field == Field.email
              ? Icons.email_outlined
              : field == Field.phone
                  ? Icons.phone_outlined
                  : field == Field.password
                      ? Icons.lock_outlined
                      : Icons.person_outlined,
          color: const Color(0xFFef2b7c),
          size: 20,
        ),
        suffixIcon: field == Field.password
            ? _passwordController.text.isNotEmpty
                ? IconButton(
                    onPressed: () => _togglePasswordObscure(),
                    icon: Icon(
                      obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: const Color(0xFF0095a0),
                      size: 20,
                    ),
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 2,
            color: Color(0xFFef2b7c),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            width: 1,
            color: Colors.grey.shade300,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            width: 2,
            color: Colors.red,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6F0FF), Color(0xFFF8F5FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 500 : double.infinity,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(isDesktop ? 48.0 : 32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo/Image
                        Center(
                          child: Image.asset(
                            'assets/icons/goturey@4x.png',
                            height: isDesktop ? 120 : 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        if (!isLogin) ...[
                          const SizedBox(height: 24),
                          ProfileImagePicker(selectImage: _selectPhoto),
                        ],
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            isLogin
                                ? 'Welcome Back!'
                                : 'Create Account',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: isDesktop ? 32 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            isLogin
                                ? 'Sign in to continue shopping'
                                : 'Join us and start shopping',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        !isLogin
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _accountType = AccountType.customer;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _accountType == AccountType.customer
                                                ? const Color(0xFFef2b7c)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Customer',
                                              style: TextStyle(
                                                color: _accountType == AccountType.customer
                                                    ? Colors.white
                                                    : Colors.grey.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _accountType = AccountType.vendor;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _accountType == AccountType.vendor
                                                ? const Color(0xFF0095a0)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Vendor',
                                              style: TextStyle(
                                                color: _accountType == AccountType.vendor
                                                    ? Colors.white
                                                    : Colors.grey.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                        SizedBox(height: isLogin ? 32 : 24),
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
                                    const SizedBox(height: 16),
                                    !isLogin
                                        ? kTextField(
                                            _fullnameController,
                                            'John Doe',
                                            'Fullname',
                                            Field.fullname,
                                            false,
                                          )
                                        : const SizedBox.shrink(),
                                    SizedBox(height: isLogin ? 0 : 16),
                                    !isLogin
                                        ? kTextField(
                                            _phoneController,
                                            '+60-000-000-000',
                                            'Phone Number',
                                            Field.phone,
                                            false,
                                          )
                                        : const SizedBox.shrink(),
                                    SizedBox(height: isLogin ? 0 : 16),
                                    kTextField(
                                      _passwordController,
                                      '********',
                                      'Password',
                                      Field.password,
                                      obscure,
                                    ),
                                    SizedBox(height: isLogin ? 24 : 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFef2b7c),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () => _handleAuth(),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isLogin ? Icons.login : Icons.person_add,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              isLogin ? 'Sign In' : 'Sign Up',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Divider
                                    Row(
                                      children: [
                                        Expanded(child: Divider(color: Colors.grey.shade300)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'OR',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(child: Divider(color: Colors.grey.shade300)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey.shade700,
                                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () => _googleAuth(),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/google.png',
                                            width: 20,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            isLogin
                                                ? 'Sign in with Google'
                                                : 'Sign up with Google',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Forgot Password (only for login)
                                    if (isLogin)
                                      Center(
                                        child: TextButton(
                                          onPressed: () => _forgotPassword(),
                                          child: const Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              color: Color(0xFF0095a0),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: isLogin ? 8 : 24),
                                    // Switch between login/signup
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            isLogin
                                                ? "Don't have an account? "
                                                : "Already have an account? ",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => _switchLog(),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              minimumSize: const Size(0, 0),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            child: Text(
                                              isLogin ? 'Sign Up' : 'Sign In',
                                              style: const TextStyle(
                                                color: Color(0xFFef2b7c),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
