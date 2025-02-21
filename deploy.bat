@echo off
echo === Step 1: Listing out the logins ===
firebase login:list
echo =======================================
echo.

echo === Step 2: Switching to primary account (epsiloninfinityservices@gmail.com) ===
firebase login:use epsiloninfinityservices@gmail.com
echo =======================================
echo.

echo === Step 3: Listing projects in primary account ===
firebase projects:list
echo =======================================
echo.

echo === Step 4: Switching to project web-epsilon-diary ===
firebase use web-epsilon-diary
echo =======================================
echo.

echo === Step 5: Build to primary account ===
flutter build web --dart-define=FIREBASE_ENV=primary --web-renderer html --release
echo =======================================
echo.

echo === Step 6: Deploy to primary project ===
firebase deploy --only hosting --project web-epsilon-diary
echo =======================================
echo.

echo === Step 7: List logins again ===
firebase login:list
echo =======================================
echo.

echo === Step 8: Logging into secondary account (admin@epsiloninfinityservices.com) ===
firebase login:use admin@epsiloninfinityservices.com
echo =======================================
echo.

echo === Step 9: Listing projects for secondary account ===
firebase projects:list
echo =======================================
echo.

echo === Step 10: Switching to epsilondiary project ===
firebase use epsilondiary
echo =======================================
echo.

echo === Step 11: Build to secondary account ===
flutter build web --dart-define=FIREBASE_ENV=secondary --web-renderer html --release
echo =======================================
echo.

echo === Step 12: Deploy to secondary project ===
firebase deploy --only hosting --project epsilondiary
echo =======================================
echo.

echo Deployment process complete!
pause
