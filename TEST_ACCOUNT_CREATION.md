# 🧪 Test Account Creation for Login Testing

Since you mentioned that login is not working, you need to create a test account first. Here are the steps:

## 📱 **Method 1: Use the Signup Screen**
1. Go to the signup screen in your app
2. Create an account with:
   - **Email**: `test@example.com`
   - **Password**: `Test123!@#`
   - Accept terms and conditions
3. Then try logging in with the same credentials

## 🔧 **Method 2: Create Account via Firebase Console**
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Authentication → Users**
4. Click **Add User**
5. Add:
   - **Email**: `test@example.com`
   - **Password**: `Test123!@#`

## 🧪 **Method 3: Quick Test Code (Temporary)**
Add this temporary button to your login screen for testing:

```dart
// Add this in your login form, just for testing
ElevatedButton(
  onPressed: () async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'Test123!@#',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Test account created!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account might already exist: $e')),
      );
    }
  },
  child: Text('Create Test Account'),
),
```

## ✅ **Test Login Credentials**
After creating the account, use these credentials to test login:
- **Email**: `test@example.com`
- **Password**: `Test123!@#`

## 🔍 **Debugging Steps**
1. Check Firebase Console → Authentication → Users to see if account was created
2. Check your app's debug console for any error messages
3. Make sure Firebase is properly configured with your SHA keys
4. Verify internet connection on your device/emulator

## 🚨 **Common Issues**
- **Firebase not initialized**: Make sure `Firebase.initializeApp()` is called in `main.dart`
- **Network issues**: Check internet connection
- **SHA keys**: Make sure you added the correct SHA1/SHA256 to Firebase Console
- **Package name**: Verify the package name matches between your app and Firebase project

Try creating an account first, then test the login functionality!