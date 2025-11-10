# 🔄 세션 재개 가이드

컴퓨터를 다시 켜고 Claude를 다시 시작했을 때 이렇게 하세요!

---

## 📝 Claude에게 이렇게 말하세요

### 방법 1: 간단한 명령어
```
SESSION_SUMMARY.md 파일을 읽고 작업을 이어서 해줘
```

### 방법 2: 더 구체적인 명령어
```
/Users/jihong/code/apps/habitcircuit/SESSION_SUMMARY.md 파일을 읽고,
현재 진행 상황을 파악한 다음, 웹 서버를 실행하고 테스트를 계속해줘
```

### 방법 3: 문제가 있을 때
```
루틴 공유 웹 페이지 작업 중이었어.
SESSION_SUMMARY.md를 읽고 어디까지 했는지 알려주고,
지금 무엇을 해야 하는지 단계별로 안내해줘
```

---

## 🎯 Claude가 자동으로 할 일

Claude가 `SESSION_SUMMARY.md`를 읽으면 자동으로:

1. ✅ 프로젝트 상황 파악
2. ✅ 어디까지 완료했는지 확인
3. ✅ 다음에 해야 할 작업 제시
4. ✅ 필요하면 웹 서버 자동 실행
5. ✅ 테스트 가이드 제공

---

## 🚀 빠른 시작 (직접 하고 싶다면)

### 1. 터미널 열기
```bash
cd /Users/jihong/code/apps/habitcircuit/routine-sharing-web
python -m http.server 8000
```

### 2. 브라우저 열기
- **시크릿 모드**: `Cmd + Shift + N`
- 주소: `http://localhost:8000`
- **F12** (개발자 도구)

### 3. 테스트 시작
- "공유하기" → "직접 작성"
- 폼 작성 후 업로드 테스트

---

## 📚 주요 문서 위치

모든 문서는 `/Users/jihong/code/apps/habitcircuit/` 폴더에 있습니다:

- **SESSION_SUMMARY.md** ← 가장 중요! 모든 작업 내용 정리
- **FIREBASE_SETUP_CHECKLIST.md** ← Firebase 설정 가이드
- **RESUME_INSTRUCTIONS.md** ← 이 문서

---

## 💡 팁

### Claude에게 물어볼 수 있는 것들

1. **현재 상황 확인**
   ```
   지금 어디까지 했어? 다음에 뭘 해야 해?
   ```

2. **문제 발생 시**
   ```
   웹 서버 실행했는데 에러가 나. 어떻게 해?
   ```

3. **테스트 방법**
   ```
   로컬에서 업로드 테스트 어떻게 해?
   ```

4. **배포 준비**
   ```
   로컬 테스트 끝났어. 이제 GitHub Pages에 배포하려면?
   ```

---

**중요**: 항상 `SESSION_SUMMARY.md` 파일이 최신 상태로 유지됩니다!
