# TaskPro - Week 3 Changelog

## 📅 Week 3 Updates (October 2025)

### 🔌 API & JSON Integration

#### Screens Connected to JSON/API:
- **Task List Screen** (`task_list_screen.dart`)
  - Now fetches tasks from JSON storage via `task_service.dart`
  - Displays real-time data instead of hardcoded tasks
  - Supports dynamic task updates

- **Task Detail Screen** (`task_detail_screen.dart`)
  - Retrieves individual task data from JSON
  - Updates task information through API calls
  - Deletes tasks with JSON service integration

- **Home Screen** (`home_screen.dart`)
  - Dashboard displays live task statistics
  - Shows pending vs completed tasks from JSON data

---

### 📝 Forms Added

#### 1. Signup Form (`signup_screen.dart`)
**Purpose:** User registration and account creation

**Fields:**
- Email address
- Password
- Confirm Password

**Validation Rules:**
- Email: Must be valid format (contains @ and domain)
- Password: Minimum 6 characters required
- Confirm Password: Must match password field
- All fields are required (cannot be empty)

**How it Works:**
1. User enters registration details
2. Form validates input in real-time
3. On submit, `auth_service.dart` processes registration
4. Success: User redirected to Home Screen
5. Error: Display appropriate error message

---

#### 2. Login Form (`login_screen.dart`)
**Purpose:** User authentication

**Fields:**
- Email address
- Password

**Validation Rules:**
- Email: Cannot be empty, must be valid format
- Password: Cannot be empty

**How it Works:**
1. User enters credentials
2. Form validates input fields
3. `auth_service.dart` verifies credentials
4. Success: Navigate to Home Screen
5. Failure: Show "Invalid credentials" error

---

#### 3. Task Creation/Edit Form (`task_detail_screen.dart`)
**Purpose:** Add new tasks or edit existing ones

**Fields:**
- Task Title (required)
- Description (optional)
- Priority (dropdown: High/Medium/Low)
- Due Date (date picker)
- Status (Complete/Pending toggle)

**Validation Rules:**
- Title: Cannot be empty, minimum 3 characters
- Priority: Must select one option
- Due Date: Cannot be in the past

**How it Works:**
1. User fills in task details
2. Form validates all required fields
3. `task_service.dart` saves to JSON storage
4. Success message displayed
5. Task list automatically refreshes

---

### ⚙️ Loading & Error Handling

#### Loading States:
- **CircularProgressIndicator** shown while:
  - Fetching task list from JSON
  - Submitting forms (signup/login/task creation)
  - Updating or deleting tasks
- Prevents user interaction during operations

#### Error Handling:
- **Form Validation Errors:**
  - Real-time error messages below input fields
  - Red text indicating what needs correction
  
- **API/JSON Errors:**
  - Network failure: "Unable to connect. Please try again."
  - Data not found: "No tasks available"
  - Save failure: "Failed to save task. Please retry."

- **Authentication Errors:**
  - Invalid login: "Incorrect email or password"
  - Signup failure: "Email already exists"
  - Session timeout: Auto-redirect to login

#### Success Feedback:
- SnackBar notifications for successful operations
- Visual confirmation (green checkmarks)
- Automatic screen navigation after success

---

### 🔄 CRUD Operations

All CRUD operations now work with JSON data through `task_service.dart`:

- **Create:** Add new tasks via task creation form
- **Read:** Fetch and display all tasks from JSON
- **Update:** Edit existing tasks and save changes
- **Delete:** Remove tasks with confirmation dialog
- **Search:** Filter tasks by title/description in real-time

---

### 🛠️ Technical Implementation

**Services Created:**
- `auth_service.dart` - Handles user authentication
- `task_service.dart` - Manages all task CRUD operations with JSON

**Data Flow:**
1. User interacts with UI (screens)
2. Form validates input
3. Service layer processes request
4. JSON data updated/retrieved
5. UI updates with new data

**Key Features:**
- Persistent data storage using JSON
- State management for real-time updates
- Form validation with user-friendly messages
- Responsive error handling

---

### 📊 Summary of Changes

| Feature | Status | Implementation |
|---------|--------|----------------|
| JSON Integration | ✅ Complete | All screens connected |
| Signup Form | ✅ Complete | Full validation added |
| Login Form | ✅ Complete | Authentication working |
| Task Forms | ✅ Complete | Create/Edit with validation |
| CRUD Operations | ✅ Complete | Fully functional |
| Search Feature | ✅ Complete | Real-time filtering |
| Error Handling | ✅ Complete | Comprehensive coverage |
| Loading States | ✅ Complete | All async operations |

---

### 🐛 Known Issues
- None reported

### 🔜 Next Steps (Week 4)
- Add task categories
- Implement due date reminders
- Enhance search with filters
- Add dark mode support

---

**Developer:** Azmi  
**Date:** October 27, 2025  
**Version:** 1.1.0
```

---

## Option 2: WEEK3_DOCUMENTATION.pdf
If you prefer PDF, create the same content above and export it as PDF.

---

## 📁 Final File Structure

Your repository should have:
```
taskpro/
├── lib/
│   ├── main.dart
│   ├── screens/
│   └── services/
├── README.md (updated with navigation flow)
├── CHANGELOG.md (or WEEK3_DOCUMENTATION.pdf)
└── .gitignore