# Render Deployment Guide

This document outlines the complete process to deploy **ExpedientLog** on Render.

## Overview

ExpedientLog is a PHP-based web application that manages expedient logs and tickets. On Render, it will run as:
- **Web Service:** PHP 8.2 with Apache (Docker)
- **Managed Database:** MySQL 8.0+ (Render's database service)
- **Persistent Storage:** Render Disk for uploaded files

---

## Prerequisites

- GitHub account with this repository pushed (commit already ready: `504b3c0`)
- Render account (https://render.com)
- Basic knowledge of environment variables and database setup

---

## Step 1: Repository Already Prepared ✅

Your repository is ready with:
- ✅ `Dockerfile` configured for PHP 8.2 + Apache
- ✅ `.dockerignore` optimizing image size
- ✅ `.env.example` with full config reference
- ✅ Commit `504b3c0` pushed to GitHub main branch

Verify on GitHub: https://github.com/Pateh-mj/ExpedientLog

---

## Step 2: Create Render Account & Connect GitHub

### 2.1 Sign Up / Log In
1. Go to [render.com](https://render.com)
2. Click **Sign Up** (or log in if you have an account)
3. Choose **GitHub** as auth provider
4. Authorize Render to access your GitHub repositories

### 2.2 Create New Service
1. From the Render dashboard, click **New +** → **Web Service**
2. Select **Build and deploy from a Git repository**
3. Search for **ExpedientLog** (or Pateh-mj/ExpedientLog)
4. Click **Connect** next to your repository

---

## Step 3: Configure Web Service

### 3.1 Basic Settings
In the service creation form, set:

| Setting | Value |
|---------|-------|
| **Name** | `expedientlog` (or your choice) |
| **Environment** | `Docker` |
| **Branch** | `main` |
| **Root Directory** | `.` (leave blank or use root) |
| **Dockerfile Path** | `./Dockerfile` (default) |

### 3.2 Environment Variables (Will Add Later)
Leave blank for now; we'll add them after the database is created.

### 3.3 Instance Type
- Start with **Starter** ($7/month) or **Standard** for production load
- Can upgrade later if needed

### 3.4 Create Service
Click **Create Web Service**. Render will begin building the Docker image.

---

## Step 4: Create Managed MySQL Database

### 4.1 Provision MySQL
1. From the Render dashboard, click **New +** → **MySQL**
2. Configure:

| Setting | Value |
|---------|-------|
| **Name** | `expedientlog-db` |
| **Database** | `exp_log` |
| **Username** | `root` (or custom) |
| **Region** | Same as web service (e.g., Ohio, Oregon) |
| **Pricing Plan** | **Starter** ($15/month) or higher |

3. Click **Create Database**
4. Render will provision the MySQL instance (takes ~10 minutes)

### 4.2 Get Connection Details
Once the database is ready:
1. Click on the **expedientlog-db** service
2. Go to the **Connections** tab
3. Copy these values:
   - **Internal Database URL** (for same region connections)
   - Or extract from the URL: `host`, `port`, `user`, `password`, `database`

Example URL format: `mysql://root:password@hostname:3306/exp_log`

---

## Step 5: Set Environment Variables

### 5.1 Add Variables to Web Service
1. Go back to the **expedientlog** web service
2. Click **Environment** (left sidebar)
3. Add the following variables:

#### Database Variables
```
DB_HOST=<internal-host-from-db-connections-tab>
DB_PORT=3306
DB_NAME=exp_log
DB_USER=root
DB_PASS=<password-from-database>
```

#### Application Variables
```
APP_NAME=ExpedientLog
APP_DEBUG=false
APP_TIMEZONE=Africa/Lusaka
APP_ENV=production
```

#### Optional: S3 for Persistent Uploads
```
S3_BUCKET=your-bucket-name
S3_KEY=your-aws-access-key
S3_SECRET=your-aws-secret-key
S3_REGION=us-east-1
```

### 5.2 Save & Redeploy
After adding variables:
1. Click **Save Changes**
2. Render will automatically redeploy the web service with new env vars
3. Check **Logs** to confirm the service starts without errors

---

## Step 6: Initialize Database Schema

### 6.1 Option A: Using Render's Database Admin UI (Easiest)
1. Click on your **expedientlog-db** database service
2. Look for a **Database Administration Tool** link (e.g., phpMyAdmin or Adminer if configured)
3. Or use the **Connections** tab to get credentials and connect with a local tool

### 6.2 Option B: Using MySQL CLI (Local)
From your local machine:

```bash
# Set credentials from Render database
MYSQL_HOST="<your-render-host>"
MYSQL_PORT="3306"
MYSQL_USER="root"
MYSQL_PASSWORD="<your-render-password>"
MYSQL_DATABASE="exp_log"

# Run the schema
mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < schema.sql
```

### 6.3 Verify Tables
Log into your database and run:

```sql
SHOW TABLES;
```

You should see tables like: `users`, `tickets`, `announcements`, etc.

---

## Step 7: Verify Deployment

### 7.1 Check Web Service Status
1. Go to the **expedientlog** web service
2. Check the **Status** indicator:
   - 🟢 **Running** = Service is live
   - 🟡 **Deploying** = Still building/starting
   - 🔴 **Failed** = Check logs

### 7.2 View Logs
1. Click the **Logs** tab
2. Look for:
   - `apache2-foreground` starting successfully
   - No fatal PHP errors
   - Successful database connection

**Example healthy log output:**
```
AH00094: Command line: 'apache2 -D FOREGROUND'
```

### 7.3 Access Your App
1. Go to the **Render Dashboard** → **expedientlog** service
2. Look for the **URL** at the top (e.g., `https://expedientlog.onrender.com`)
3. Click the link or copy it to your browser
4. You should see the ExpedientLog login page or dashboard

### 7.4 Test Functionality
- ✅ Load the homepage / login page
- ✅ Test authentication (login with test user)
- ✅ Navigate to main features (dashboard, announcements, etc.)
- ✅ Test file uploads (if applicable)

---

## Step 8: Persistent Storage for File Uploads

### 8.1 Understanding Render's Filesystem
- Render web services have **ephemeral** storage by default
- Files in `/var/www/html/storage/uploads` are lost on redeploy/restart

### 8.2 Add a Persistent Disk

1. Go to the **expedientlog** web service
2. Click **Disks** (left sidebar)
3. Click **Add Disk**
4. Configure:

| Setting | Value |
|---------|-------|
| **Name** | `expedientlog-uploads` |
| **Mount Path** | `/var/www/html/storage/uploads` |
| **Size** | Start with 10GB ($5/month per 10GB) |

5. Click **Create Disk**

### 8.3 Verify Disk is Mounted
- Service will automatically redeploy
- Check logs for successful start
- Uploaded files will now persist across restarts

### 8.4 Alternative: Use S3 (More Scalable)
Instead of a Render Disk:
1. Configure AWS S3 credentials (see Step 5.1)
2. Update file upload code in [src/Core/FileUpload.php](src/Core/FileUpload.php) to use S3
3. Uploads scale better and cost less for large files

---

## Step 9: Custom Domain (Optional)

### 9.1 Add Custom Domain
1. Go to the **expedientlog** web service
2. Click **Settings** (left sidebar)
3. Scroll to **Custom Domain**
4. Enter your domain (e.g., `logs.example.com`)
5. Render will provide DNS instructions
6. Update your DNS provider to point to Render's CNAME

### 9.2 SSL/TLS
- Render automatically provisions free SSL certificates via Let's Encrypt
- Your app will be accessible via `https://logs.example.com`

---

## Troubleshooting

### Service Fails to Start
**Check logs:**
1. Go to **Logs** tab
2. Look for errors like `DB connection failed` or PHP syntax errors
3. Common issues:
   - `DB_HOST` or `DB_PASS` incorrect → verify in database Connections tab
   - Missing PHP extensions → confirm Dockerfile installs them (it does)

**Solution:**
- Fix environment variables
- Redeploy: **Dashboard** → Service → **Rerun latest deploy**

### Can't Connect to Database
1. Verify database service is **Running** (check database dashboard)
2. Confirm internal host is used (not external URL if in same region)
3. Try connecting locally to test credentials:
   ```bash
   mysql -h <host> -u root -p<password> exp_log -e "SELECT 1;"
   ```

### 403 Forbidden or 404 Errors
- Verify `.htaccess` is in the repo (it is)
- Dockerfile enables `mod_rewrite` (correct)
- Try accessing `https://yoururl/public/index.php` directly
- Check if the router is parsing requests correctly in logs

### Files Lost After Restart
- Confirm persistent disk is mounted at `/var/www/html/storage/uploads`
- Check disk size hasn't been exceeded
- Use S3 for more reliability (see Step 8.4)

---

## Monitoring & Maintenance

### 1. Enable Auto-Deploy from GitHub
- Already enabled by default
- Any commit to `main` triggers a redeploy

### 2. Monitor Service Health
- Render dashboard shows CPU, memory, and request metrics
- Set up alerts in **Render Dashboard** → **Account Settings** → **Notifications**

### 3. Database Backups
- Render's managed MySQL includes daily backups (retention depends on plan)
- Download backups from the database service dashboard if needed

### 4. Scaling
- Increase instance size if traffic grows
- Add more replicas (only on paid plans)
- Use Render's analytics to monitor performance

---

## Cost Estimation (as of 2026)

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| Web Service (PHP + Apache) | Starter | $7 |
| MySQL Database | Starter | $15 |
| Persistent Disk (10GB) | - | $5 |
| **Total** | | **~$27/month** |

*Costs increase with traffic, storage, and higher instance tiers.*

---

## Success Criteria

Your deployment is successful when:

✅ Web service status is **Running** (green)  
✅ Database is **Running** (green)  
✅ App is accessible at your Render URL (https://...)  
✅ Can log in with test credentials  
✅ Database tables are present  
✅ File uploads work (or S3 configured)  
✅ Logs show no critical errors  
✅ Persistent disk mounted (if using disk for uploads)  

---

## Next Steps Summary

1. ✅ **Repository pushed** (commit `504b3c0` on GitHub main)
2. **Create Render web service** from GitHub integration
3. **Create Render MySQL database**
4. **Set environment variables** on web service
5. **Initialize schema** (`schema.sql`) in database
6. **Add persistent disk** for file uploads
7. **Verify** the app is running and accessible

---

## Additional Resources

- [Render Documentation](https://render.com/docs)
- [Render Docker Guide](https://render.com/docs/docker)
- [Render MySQL Guide](https://render.com/docs/mysql)
- [Render Disks](https://render.com/docs/disks)
- [Render Custom Domains](https://render.com/docs/custom-domains)

---

**Last Updated:** 2026-06-12  
**Status:** Ready for Render Deployment
