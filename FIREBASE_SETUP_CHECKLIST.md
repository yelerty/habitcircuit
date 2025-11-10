# 🔥 Firebase 설정 체크리스트

웹 앱 업로드 문제 해결을 위한 Firebase 설정 확인 사항입니다.

## ✅ 1. Firebase Authentication 활성화

1. [Firebase Console](https://console.firebase.google.com/project/routine-sharing/authentication/providers) 접속
2. **Authentication** → **Sign-in method** 탭
3. **Anonymous** 항목 찾기
4. **Enable** 스위치 켜기
5. **저장** 버튼 클릭

### 확인 방법:
- Anonymous 항목이 "Enabled" 상태여야 합니다

---

## ✅ 2. Firestore Database 생성 및 규칙 적용

### 2-1. Database 생성
1. [Firestore Console](https://console.firebase.google.com/project/routine-sharing/firestore) 접속
2. **Create database** 버튼 클릭
3. **Start in production mode** 선택 (나중에 규칙 적용)
4. 리전 선택: **asia-northeast3 (Seoul)** 권장
5. **Enable** 클릭

### 2-2. 보안 규칙 적용
1. **Firestore Database** → **Rules** 탭
2. 아래 규칙을 복사하여 붙여넣기:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to validate routine data structure
    function isValidRoutine() {
      return request.resource.data.keys().hasAll(['version', 'dayOfWeek', 'timeType', 'routines', 'anonId', 'createdAt', 'likes'])
        && request.resource.data.version is string
        && request.resource.data.dayOfWeek in ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일']
        && request.resource.data.timeType in ['아침', '점심', '저녁']
        && request.resource.data.routines is list
        && request.resource.data.routines.size() > 0
        && request.resource.data.routines.size() <= 20
        && request.resource.data.anonId is string
        && request.resource.data.likes is number
        && request.resource.data.likes >= 0;
    }

    // Routines collection rules
    match /routines/{routineId} {
      // Anyone can read routines (public browsing)
      allow read: if true;

      // Create: Only authenticated users, with valid data structure
      allow create: if request.auth != null
                    && isValidRoutine()
                    && request.resource.data.anonId == request.auth.uid
                    && request.resource.data.likes == 0
                    && request.resource.data.size() < 10000;

      // Update: Only allow incrementing likes, nothing else
      allow update: if request.auth != null
                    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['likes'])
                    && request.resource.data.likes == resource.data.likes + 1
                    && request.resource.data.likes <= 1000000;

      // Delete: Only the creator can delete their own routines
      allow delete: if request.auth != null
                    && request.auth.uid == resource.data.anonId;
    }

    // Deny all other collections
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

3. **Publish** 버튼 클릭

---

## ✅ 3. 승인된 도메인 추가

1. [Authentication Settings](https://console.firebase.google.com/project/routine-sharing/authentication/settings) 접속
2. **Authorized domains** 섹션
3. 다음 도메인들이 추가되어 있는지 확인:
   - `localhost` (로컬 테스트용)
   - `127.0.0.1` (로컬 테스트용)
   - `yelerty.github.io` (배포용)

### 도메인 추가 방법:
- **Add domain** 버튼 클릭
- 도메인 입력 후 **Add** 클릭

---

## ✅ 4. 로컬 테스트

### 4-1. 웹 서버 실행
```bash
cd routine-sharing-web
python -m http.server 8000
# 또는
npx http-server -p 8000
```

### 4-2. 브라우저 개발자 도구 열기
1. 브라우저에서 `http://localhost:8000` 접속
2. **F12** 키로 개발자 도구 열기
3. **Console** 탭으로 이동

### 4-3. 인증 상태 확인
페이지 로드 후 다음 메시지가 나와야 합니다:
```
🔄 Attempting anonymous sign-in...
✅ Anonymous sign-in successful: [user-id]
✅ User signed in anonymously: [user-id]
⏳ Waiting for authentication...
✅ Auth status UI updated: authenticated
```

### 4-4. 업로드 테스트
1. **공유하기** 탭 클릭
2. **직접 작성** 선택
3. 폼 작성:
   - 요일: 월요일
   - 시간대: 아침
   - 루틴: (여러 줄로 입력)
     ```
     물 한 잔 마시기
     스트레칭 10분
     ```
4. **확인 및 업로드** 버튼 클릭
5. Console에서 다음 메시지 확인:
   ```
   📤 Starting upload process...
   Auth initialized: true
   Current user: [Object]
   📝 Uploading routines...
   ✅ Uploaded successfully
   ```

---

## 🐛 문제 해결

### 에러: "로그인이 필요합니다"
**원인**: Anonymous Authentication이 비활성화됨
**해결**: 체크리스트 #1 확인

### 에러: "권한이 거부되었습니다"
**원인**: Firestore 보안 규칙 미적용 또는 잘못된 데이터 구조
**해결**:
- 체크리스트 #2 확인
- Console에서 업로드 데이터 구조 확인

### 에러: "Authentication timeout"
**원인**: Firebase 초기화 실패 또는 네트워크 문제
**해결**:
- 인터넷 연결 확인
- Firebase Config가 올바른지 확인 (`firebase.js`)
- 브라우저 콘솔에서 에러 메시지 확인

### 페이지 로드 시 아무 에러도 없지만 업로드 안 됨
**원인**: 승인된 도메인 미등록
**해결**: 체크리스트 #3 확인

---

## 📝 테스트 완료 체크리스트

- [ ] Firebase Console에서 Authentication → Anonymous가 "Enabled" 상태
- [ ] Firestore Database 생성 완료
- [ ] Firestore 보안 규칙 적용 완료
- [ ] 승인된 도메인에 localhost 추가 완료
- [ ] 로컬에서 웹 서버 실행 성공
- [ ] 브라우저 Console에 "✅ User signed in anonymously" 메시지 표시
- [ ] 우측 상단에 "✅ 인증 완료" 표시
- [ ] 테스트 루틴 업로드 성공
- [ ] "둘러보기" 탭에서 업로드한 루틴 확인 가능

---

## 🎯 다음 단계

모든 체크리스트를 완료한 후:
1. GitHub Pages에 배포
2. Firebase Console에서 `yelerty.github.io` 도메인 추가
3. iOS 앱에서 실제 JSON 파일 업로드 테스트
4. 웹에서 다운로드 후 iOS 앱으로 가져오기 테스트

---

**마지막 업데이트**: 2025-11-01
