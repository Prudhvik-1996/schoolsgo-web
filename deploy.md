
# Firebase Deployment Script

This document outlines the steps for deploying a Flutter web application to Firebase using two different accounts and projects.
1. web-epsilon-diary.web.app owned by epsiloninfinityservices@gmail.com
2. epsilondiary.web.app owned by admin@epsiloninfinityservices.com

## Step 1: Listing out the logins

```bash  
firebase login:list
```  
  
---  

## Step 2: Switching to primary account (`epsiloninfinityservices@gmail.com`)

```bash  
firebase login:use epsiloninfinityservices@gmail.com
```  
  
---  

## Step 3: Listing projects in primary account

```bash  
firebase projects:list
```  
  
---  

## Step 4: Switching to project `web-epsilon-diary`

```bash  
firebase use web-epsilon-diary
```  
  
---  

## Step 5: Build to primary account

```bash  
flutter build web --dart-define=FIREBASE_ENV=primary --web-renderer html --release
```  
  
---  

## Step 6: Deploy to primary project

```bash  
firebase deploy --only hosting --project web-epsilon-diary
```  
  
---  

## Step 7: List logins again

```bash  
firebase login:list
```  
  
---  

## Step 8: Logging into secondary account (`admin@epsiloninfinityservices.com`)

```bash  
firebase login:use admin@epsiloninfinityservices.com
```  
  
---  

## Step 9: Listing projects for secondary account

```bash  
firebase projects:list
```  
  
---  

## Step 10: Switching to `epsilondiary` project

```bash  
firebase use epsilondiary
```  
  
---  

## Step 11: Build to secondary account

```bash  
flutter build web --dart-define=FIREBASE_ENV=secondary --web-renderer html --release
```  
  
---  

## Step 12: Deploy to secondary project

```bash  
firebase deploy --only hosting --project epsilondiary
```  
  
---  

## Deployment process complete!

This Markdown file provides a clear and structured overview of the deployment process.