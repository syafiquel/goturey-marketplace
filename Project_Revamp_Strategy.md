# Project Revamp Strategy

This document outlines the proposed strategy for refactoring the Goturey Marketplace application, covering both architectural separation of user types and a comprehensive UI/UX revamp.

## 1. Architectural Strategy: App Separation

### Analysis
The application is well-structured for separation. User data is stored in separate `customers` and `vendors` collections, and the UI navigation logic is cleanly separated by a single `isCustomer` flag.

### Conclusion
Separating the app into distinct "Customer" and "Vendor" applications is **feasible with low-to-medium effort**. The primary task is package setup, not complex code refactoring.

### Proposed Architecture
A three-package structure is recommended for optimal maintainability:

1.  **`goturey_core` (Shared Library):** A new package to house all shared code:
    *   Data Models (`/models`)
    *   State Providers (`/providers`)
    *   Business Logic (`/controllers`, `/helpers`)
    *   Shared Resources & Widgets (`/resources`, `/constants`, common widgets)

2.  **`goturey_customer` (New App):** A lightweight app for customers, depending on `goturey_core`. It will contain only customer-specific views and a direct entry point (`main.dart`).

3.  **`goturey_vendor` (New App):** A lightweight app for vendors, also depending on `goturey_core`. It will contain only vendor-specific views and its own `main.dart`.

## 2. UI/UX Revamp Plan

This plan will be executed on the current, unified codebase. The changes are designed to be easily portable to the split architecture later.

### Analysis Summary
*   **Theming:** Inconsistent color usage undermines the existing theme structure. The color palette is dated.
*   **Layout:** Some screens have critical responsiveness issues (e.g., hardcoded heights). Spacing is inconsistent.
*   **Code Structure:** Good component separation exists, but some screens have cluttered logic.

### Phased Implementation

**Phase 1: Modernize Theme and Colors**
1.  **New Color Palette:** Introduce a softer, modern palette (Calm Blue, Neutral Accent, Off-White Background, Dark Grey Text).
2.  **Centralize Styles:** Refactor `theme_manager.dart` to be the single source of truth for all colors and text styles, fully utilizing the `ThemeData` object.

**Phase 2: Refactor Layouts for Responsiveness & Clarity**
1.  **Fix Critical Layouts:** Address responsiveness bugs, starting with the `home_screen.dart` product grid.
2.  **Extract Logic:** Clean up cluttered widgets by extracting business logic into dedicated controllers or widgets.
3.  **Apply Theme:** Systematically replace all hardcoded `Color` and `TextStyle` instances with references from the central theme (e.g., `Theme.of(context).textTheme.bodyMedium`).

**Phase 3: Incremental Rollout**
1.  **Update All Screens:** Progressively apply the new design standards and refactoring patterns to all other screens for a consistent look and feel.

## 3. Immediate Action Plan

1.  Proceed with **Phase 1** of the UI/UX Revamp.
2.  The first concrete step is to **update the color palette in `lib/constants/color.dart`**.
3.  After each successful change, a commit will be made to track progress.
