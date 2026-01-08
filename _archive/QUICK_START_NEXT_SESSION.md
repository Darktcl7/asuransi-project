# QUICK START - NEXT SESSION
**Last Updated:** 2025-11-24

---

## 🚀 START HERE (Copy-Paste Ready)

### **Step 1: Start Servers**

```bash
# Terminal 1: Backend (Django)
cd "D:\Django Project\Asuransi Project\Smile Project"
.\env\Scripts\python.exe manage.py runserver

# Terminal 2: Admin Dashboard (React)
cd "D:\Django Project\Asuransi Project\admin-dashboard"
npm run dev

# Terminal 3: Available for commands
cd "D:\Django Project\Asuransi Project\Smile Project"
```

---

### **Step 2: Verify Everything Works**

```bash
# Quick health check
.\env\Scripts\python.exe quick_dashboard_check.py

# Expected output:
# ✅ Total Users: 1,008
# ✅ Active Policies: 10
# ✅ Total Balance: Rp 45M
```

**Open in browser:**
- Admin Dashboard: http://localhost:5174
- API Docs: http://127.0.0.1:8000/api/

**Login:**
- Email: chluik277@gmail.com
- Password: admin123

---

### **Step 3: Choose Your Mission**

#### **🎯 Mission A: Policy Expiry UI (2-3 hours)**
**Goal:** Show expiry dates everywhere

**Tasks:**
1. Add expiry date column in Policies table
2. Add color indicator (green/yellow/red)
3. Add "Expires in X days" label
4. Test with existing policies

**Files to edit:**
- `admin-dashboard/src/pages/PoliciesPage.jsx`
- `admin-dashboard/src/services/adminService.js`

**Start command:**
```javascript
// PoliciesPage.jsx - Add column
{
  label: 'Expiry Date',
  render: (policy) => {
    const daysLeft = calculateDaysLeft(policy.created_at);
    return <ExpiryBadge days={daysLeft} />;
  }
}
```

---

#### **🎯 Mission B: Email Notifications (3-4 hours)**
**Goal:** Send emails on claim status change

**Tasks:**
1. Configure email in settings.py
2. Create email templates
3. Send email on claim approval
4. Test email sending

**Files to create/edit:**
- `config/settings.py` (email config)
- `utils/email_service.py` (NEW)
- `claims/views.py` (add send_email call)
- `templates/email/claim_approved.html` (NEW)

**Start command:**
```bash
# Create email service
cd "D:\Django Project\Asuransi Project\Smile Project"
mkdir -p utils
touch utils/email_service.py
```

**Code to add:**
```python
# config/settings.py
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'your-email@gmail.com'
EMAIL_HOST_PASSWORD = 'your-app-password'
```

---

#### **🎯 Mission C: Data Export (2-3 hours)**
**Goal:** Export data to Excel

**Tasks:**
1. Install openpyxl: `pip install openpyxl`
2. Add export endpoint in admin_api/views.py
3. Add export button in admin dashboard
4. Test download

**Start commands:**
```bash
# Install library
cd "D:\Django Project\Asuransi Project\Smile Project"
.\env\Scripts\python.exe -m pip install openpyxl
```

**Backend code:**
```python
# admin_api/views.py
from openpyxl import Workbook
from django.http import HttpResponse

@action(detail=False, methods=['get'])
def export_excel(self, request):
    wb = Workbook()
    ws = wb.active
    ws.title = "Users"
    
    # Headers
    ws.append(['ID', 'Email', 'Name', 'KTP', 'Created'])
    
    # Data
    users = User.objects.all()
    for user in users:
        ws.append([
            user.id,
            user.email,
            user.full_name,
            user.ktp_number,
            user.date_joined.strftime('%Y-%m-%d')
        ])
    
    response = HttpResponse(
        content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    )
    response['Content-Disposition'] = 'attachment; filename=users.xlsx'
    wb.save(response)
    return response
```

**Frontend code:**
```javascript
// UsersPage.jsx
const handleExport = async () => {
  const blob = await adminService.exportUsers();
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'users.xlsx';
  a.click();
};

<button onClick={handleExport}>
  📥 Export to Excel
</button>
```

---

#### **🎯 Mission D: Claim Workflow (4-5 hours)**
**Goal:** Complete claim lifecycle

**Tasks:**
1. Add "in_progress" status
2. Add status transition buttons
3. Add payment proof upload
4. Add notification on status change

**Files to edit:**
- `claims/models.py` (add status choices)
- `admin_api/views.py` (add status actions)
- `admin-dashboard/src/pages/ClaimsPage.jsx`

**Start command:**
```python
# claims/models.py
class Claim(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('in_progress', 'In Progress'),  # NEW
        ('approved', 'Approved'),
        ('completed', 'Completed'),  # NEW
        ('rejected', 'Rejected'),
    ]
```

---

## 📋 TODO TEMPLATE

Create this file when starting:

```markdown
# TODO - [Mission Name]
Date: 2025-11-XX

## Tasks
- [ ] Task 1
- [ ] Task 2
- [ ] Task 3

## Progress
- Started: XX:XX
- Completed: XX:XX
- Duration: X hours

## Issues Encountered
- Issue 1: ...
- Issue 2: ...

## Testing
- [ ] Manual test passed
- [ ] API test passed
- [ ] UI test passed

## Notes
- ...
```

---

## 🔍 USEFUL COMMANDS

### **Database:**
```bash
# Django shell
.\env\Scripts\python.exe manage.py shell

# Check user count
python -c "from users.models import User; print(User.objects.count())"

# Check claims
python -c "from claims.models import Claim; print(Claim.objects.filter(status='pending').count())"
```

### **Testing:**
```bash
# Test dashboard API
.\env\Scripts\python.exe test_dashboard_stats.py

# Test notifications
.\env\Scripts\python.exe test_notification_api.py

# Run Django tests (if you write them)
.\env\Scripts\python.exe manage.py test
```

### **Database Backup:**
```bash
# Backup before changes
.\env\Scripts\python.exe manage.py dumpdata > backup_$(date +%Y%m%d).json

# Or copy SQLite file
copy db.sqlite3 db.sqlite3.backup
```

### **Cache Clear:**
```bash
# If dashboard stats not updating
.\env\Scripts\python.exe manage.py shell
>>> from django.core.cache import cache
>>> cache.clear()
>>> exit()
```

---

## 🐛 COMMON ISSUES & SOLUTIONS

### **Issue 1: Server not starting**
```bash
# Kill existing process
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Or change port
python manage.py runserver 8001
```

### **Issue 2: Database locked**
```bash
# Close all connections
# Restart Django server
```

### **Issue 3: Module not found**
```bash
# Reinstall requirements
.\env\Scripts\python.exe -m pip install -r requirements.txt
```

### **Issue 4: React not loading**
```bash
# Clear node_modules
cd admin-dashboard
rm -rf node_modules
npm install
npm run dev
```

### **Issue 5: CORS error**
```python
# config/settings.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:5173",
    "http://localhost:5174",
]
```

---

## 📚 HELPFUL RESOURCES

### **Documentation:**
- Django: https://docs.djangoproject.com/
- Django REST: https://www.django-rest-framework.org/
- React Query: https://tanstack.com/query/latest
- Flutter: https://flutter.dev/docs

### **Project Files:**
- Backend: `D:\Django Project\Asuransi Project\Smile Project`
- Frontend: `D:\Django Project\Asuransi Project\admin-dashboard`
- Mobile: `D:\Django Project\Asuransi Project\phone_insurance_app`

### **Key Files:**
```
Backend:
- admin_api/views.py (Admin endpoints)
- claims/models.py (Claim model)
- policies/models.py (Policy model)
- users/models.py (User model)

Frontend:
- src/pages/DashboardHome.jsx
- src/pages/ClaimsPage.jsx
- src/pages/PoliciesPage.jsx
- src/services/adminService.js

Mobile:
- lib/screens/claim/submit_claim_screen.dart
- lib/screens/claim/claim_history_screen.dart
- lib/models/claim.dart
```

---

## ✅ SESSION END CHECKLIST

**Before finishing:**
```
□ Test all changes work
□ Create git commit (if using git)
□ Update documentation
□ Update TODO list
□ Note any issues for next time
□ Backup database
□ Close all servers properly (Ctrl+C)
```

---

## 🎯 RECOMMENDED ORDER

**If starting fresh, do in this order:**

1. **Day 1-2: Email Notifications** (Foundation)
   - Most impactful for users
   - Needed for many features

2. **Day 3: Data Export** (Quick win)
   - Admin will love this
   - Easy to implement

3. **Day 4-5: Claim Workflow** (Core feature)
   - Complete the main flow
   - Add status transitions

4. **Day 6: Policy Expiry UI** (Polish)
   - Visual improvements
   - Better UX

5. **Day 7: Testing & Fixes** (Quality)
   - Fix any bugs found
   - Write tests

---

## 🔥 QUICK WINS (< 1 hour each)

If you have limited time:

1. **Add timestamps to claim cards** (15 min)
2. **Add loading spinners everywhere** (20 min)
3. **Add success/error toasts** (20 min)
4. **Add confirmation dialogs** (15 min)
5. **Improve error messages** (20 min)
6. **Add tooltips to buttons** (15 min)
7. **Add keyboard shortcuts** (30 min)
8. **Add breadcrumbs navigation** (20 min)

---

## 🎉 GOOD LUCK!

**Remember:**
- ✅ Test frequently
- ✅ Save backups
- ✅ Read error messages carefully
- ✅ Ask for help when stuck
- ✅ Take breaks!

**Start Command:**
```bash
# Just run this:
cd "D:\Django Project\Asuransi Project\Smile Project"
.\env\Scripts\python.exe manage.py runserver

# Then in another terminal:
cd "D:\Django Project\Asuransi Project\admin-dashboard"
npm run dev

# Open browser:
# http://localhost:5174
```

**Let's build! 🚀**

---

**End of Quick Start Guide**
