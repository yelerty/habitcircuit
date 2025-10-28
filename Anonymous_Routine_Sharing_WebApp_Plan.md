# 🧩 Project Plan: Anonymous Routine Sharing Web App

## 1. 🎯 Project Overview
A free web platform where users can anonymously share and browse daily routines (Morning, Lunch, Dinner) by day of the week.  
Each post is stored as a JSON entry in Firebase Firestore, accessible to everyone, and created anonymously via Firebase Auth (anonymous mode).

---

## 2. 🏗️ Architecture Overview
**Frontend**  
- Framework: Vanilla JS / React (optional)  
- Hosting: GitHub Pages or Cloudflare Pages (free)  

**Backend (Serverless)**  
- Firebase Auth (Anonymous)  
- Firebase Firestore (store routine posts)  
- Firebase Storage (optional: store original JSON file if too large)  
- Firebase Cloud Functions (optional: spam filtering, moderation)

**Flow**
1. User visits the website → automatically assigned anonymous Firebase Auth user.  
2. User writes or uploads a routine JSON.  
3. The data is uploaded to Firestore (`collection: routines`).  
4. Other users can browse routines by day and meal type.  

---

## 3. 🗂️ Firestore Data Structure

**Collection:** `routines`  
**Document Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `dayOfWeek` | string | e.g., "Monday" |
| `meal` | string | "morning", "lunch", "dinner" |
| `content` | map | JSON data of the routine |
| `anonId` | string | Auth UID (anonymous) |
| `createdAt` | timestamp | Firestore server timestamp |
| `likes` | number | Optional: for voting system |

---

## 4. 🔒 Firebase Security Rules (Concept)
```js
match /routines/{docId} {
  allow read: if true; // Public read
  allow write: if request.auth != null 
               && request.resource.data.size() < 1024 // 1KB limit
               && request.resource.data.keys().hasAll(['dayOfWeek','meal','content']);
}
```

---

## 5. 💡 Core Features
- [x] Anonymous posting via Firebase Auth  
- [x] Routine viewer (filter by day or meal type)  
- [ ] Optional “like” or “favorite” feature  
- [ ] Optional “report” button (connects to Cloud Function)  
- [x] JSON upload & preview  
- [x] Responsive UI  

---

## 6. 🧱 Project Structure
```
root/
 ├── index.html
 ├── app.js
 ├── firebase.js   # Firebase initialization
 ├── style.css
 ├── components/
 │    ├── routineCard.js
 │    ├── uploadForm.js
 └── assets/
      └── icons/
```

---

## 7. 🧩 Firebase Setup Steps
1. Create Firebase Project → Enable Authentication → Choose “Anonymous”.  
2. Enable Firestore Database (Start in Test Mode → then apply rules).  
3. Get Firebase Config → paste into `firebase.js`.  
4. Deploy frontend via GitHub Pages or Cloudflare Pages.  

---

## 8. 🚀 Development Tasks

| Task | Description | Tools |
|------|--------------|-------|
| UI Design | Minimalist daily routine layout | Figma / HTML+CSS |
| Auth Setup | Enable Firebase anonymous login | Firebase Auth |
| CRUD Implementation | Create / Read / List routines | Firestore |
| Filtering | Day & Meal type filter | JavaScript |
| Optional moderation | Cloud Functions or manual review | Firebase Functions |

---

## 9. 📦 Future Enhancements
- Personal dashboard (show user’s own uploaded routines)  
- AI-based recommendation (popular routines by category)  
- Export routines to JSON / CSV  
- Language localization (EN/KR/JP)  

---

## 10. 💰 Cost & Limits (Firebase Free Tier)
| Service | Free Limit | Notes |
|----------|-------------|-------|
| Firestore | 50k reads/day, 20k writes/day | Plenty for MVP |
| Auth | 10k active users/month | Anonymous included |
| Storage | 1GB total | For JSON backups only |

---

## 11. 🧠 Recommended Tech Stack
- HTML / CSS / JS (or React)  
- Firebase SDK v11+  
- Optional: TailwindCSS for fast UI  
- GitHub for version control  
- Cloudflare/GitHub Pages for hosting  

---

## 12. ✅ Deployment
```bash
# Build (if React)
npm run build
# Deploy (GitHub Pages)
git push origin main
# or Cloudflare
wrangler pages publish ./build
```

---

## 13. 📅 Milestone Plan

| Phase | Duration | Goal |
|-------|-----------|------|
| Phase 1 | 3 days | Firebase setup + basic UI |
| Phase 2 | 5 days | CRUD logic + JSON upload |
| Phase 3 | 2 days | Firestore security rules |
| Phase 4 | 2 days | Testing + deployment |

---

## 14. ⚙️ Example JSON Format
```json
{
  "dayOfWeek": "Monday",
  "meal": "morning",
  "content": {
    "routine": [
      "Wake up at 6:00",
      "Stretch for 10 minutes",
      "Drink water",
      "Read news for 15 minutes"
    ]
  }
}
```

---

## 15. 🧩 License
Open-source under MIT License.
