# Profile Photo Upload Fix

## Issue
Users were getting a Firestore permission denied error when trying to upload profile photos:
```
[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

## Root Cause
1. **Firestore Rules**: The original rules didn't properly handle profile image updates for the `users` collection
2. **Missing Collection Rules**: No rules were defined for the `userProfiles` collection
3. **Error Handling**: Limited debugging information made it hard to identify the exact issue

## Changes Made

### 1. Updated Firestore Security Rules (`firestore.rules`)
**Before**: Rules didn't allow profile image updates properly
**After**: Added specific handling for profile image updates:

```javascript
allow update: if isRegisteredUser() && (
  (isOwner(userId) && 
    !request.resource.data.diff(resource.data).affectedKeys().hasAny([
      'creditLimit', 'availableCredit', 'totalDebt', 'rating', 
      'isVerified', 'userType', 'createdAt'
    ]) &&
    (isValidUserData() || 
     request.resource.data.diff(resource.data).affectedKeys().hasOnly(['profileImage', 'updatedAt']))
  ) || isAdmin()
);
```

**Added rules for `userProfiles` collection**:
```javascript
match /userProfiles/{userId} {
  allow read: if isRegisteredUser() && (
    isOwner(userId) || isAdmin() || (isStoreOwner() && isVerifiedUser())
  );
  allow create: if isRegisteredUser() && isOwner(userId);
  allow update: if isRegisteredUser() && isOwner(userId);
  allow delete: if isAdmin();
}
```

### 2. Enhanced FirebaseStorageService (`lib/services/firebase_storage_service.dart`)
**Improvements**:
- Better error handling with try-catch for Firestore updates
- Fallback to `set with merge` if `update` fails
- Separated Storage upload from Firestore update for better debugging
- More detailed logging

### 3. New ProfileImageService (`lib/services/profile_image_service.dart`)
**Features**:
- Comprehensive error handling and debugging
- Separate authentication checks
- Better error messages for users
- Handles both document creation and updates
- Detailed logging for troubleshooting

### 4. Updated ProfilePhotoUpload Widget (`lib/widgets/profile_photo_upload.dart`)
**Changes**:
- Uses new ProfileImageService for better error handling
- Improved error messages for users
- Better permission-denied error handling

## Testing Steps

### For Authenticated Users:
1. **Login** as a registered user (not guest)
2. **Navigate** to Profile screen
3. **Tap** on profile photo area
4. **Select** "Take Photo" or "Choose from Gallery"
5. **Pick** an image (JPG/PNG, <5MB)
6. **Verify** upload progress shows
7. **Confirm** image appears and success message shows
8. **Try** changing the photo again
9. **Try** removing the photo

### For Guest Users:
1. **Use** app as guest (don't create account)
2. **Navigate** to Profile screen
3. **Tap** on profile photo area
4. **Verify** restriction dialog appears
5. **Confirm** "Create Account" button works

### Edge Cases:
1. **Large file** (>5MB) - should show size error
2. **Wrong format** (GIF, BMP) - should show format error
3. **Network issues** - should handle gracefully
4. **Permission changes** - should show appropriate errors

## Expected Behavior After Fix

### ✅ Success Cases:
- Authenticated users can upload profile photos
- Images are properly optimized and stored
- Firestore documents are updated with image URLs
- Users see success confirmations
- Images are cached and display correctly

### ✅ Error Handling:
- Clear error messages for file size/format issues
- Proper permission denied messages
- Network error handling
- Guest user restrictions with helpful dialogs

## Monitoring

Check the logs for these messages:
- `Profile image uploaded successfully for user: {userId}`
- `Updated profileImage in users collection`
- `Successfully created new user document with profileImage`

## Rollback Plan

If issues persist:
1. Revert Firestore rules: `firebase deploy --only firestore:rules`
2. Use original FirebaseStorageService
3. Temporarily disable profile photo upload feature

## Additional Notes

- **Security**: Only authenticated users can upload photos to their own profile
- **Storage**: Images are stored in `/profiles/{userId}/` with proper naming
- **Performance**: Images are automatically optimized (resized + compressed)
- **UX**: Progress tracking and haptic feedback for better experience
- **Accessibility**: Proper error messages and guest user guidance