# 🔍 Xcode 콘솔 로그 확인 가이드

## 1️⃣ Xcode에서 프로젝트 열기

```bash
cd /Users/jihong/code/apps/habitcircuit/HabitCircuit/HabitSeries
open HabitSeries.xcodeproj
```

## 2️⃣ 콘솔 창 표시하기

### 방법 1: 단축키 (가장 빠름!)
- **Cmd + Shift + Y** - 디버그 영역 토글
- **Cmd + Shift + C** - 콘솔만 토글

### 방법 2: 메뉴
1. Xcode 상단 메뉴
2. **View** → **Debug Area** → **Show Debug Area**

### 방법 3: 버튼
- Xcode 우측 상단 (Play 버튼 근처)
- 3개 아이콘 중 우측 아이콘 (🔧 모양) 클릭

## 3️⃣ 앱 실행 및 테스트

1. **시뮬레이터 선택**
   - Xcode 상단 중앙: "HabitSeries > iPhone 15" 같은 메뉴
   - 클릭해서 원하는 시뮬레이터 선택

2. **앱 실행**
   - **Cmd + R** 또는 ▶️ 버튼 클릭
   - 잠시 기다리면 시뮬레이터에 앱이 실행됨

3. **루틴 삭제 테스트**
   - 앱에서 루틴 편집 화면으로 이동
   - 루틴을 삭제
   - **즉시 콘솔 하단 확인!**

## 4️⃣ 로그 해석하기

### 정상적인 삭제 로그 예시:

```
🗑️ Delete started - Current routines count: 3
🗑️ Deleting routine: 물 마시기 (ID: ABC-123)
✅ Deleted from context
💾 Context saved after deletion
🔄 Context refreshed
📥 loadRoutines - Fetched 2 routines from DB
✅ loadRoutines - Updated routines to 2 items
📥 loadAllRoutines - Fetched 8 routines from DB
✅ loadAllRoutines - Updated allRoutines to 8 items
🔢 Reordering 2 routines
📊 After reorder - routines count: 2
📥 loadRoutines - Fetched 2 routines from DB
✅ loadRoutines - Updated routines to 2 items
📥 loadAllRoutines - Fetched 8 routines from DB
✅ loadAllRoutines - Updated allRoutines to 8 items
✅ Delete completed - Final routines count: 2
```

### 문제가 있는 경우 찾아야 할 것:

1. **❌ 에러 메시지**
   ```
   ❌ Error deleting routine: ...
   ❌ Error fetching routines: ...
   ```

2. **숫자 불일치**
   ```
   📥 loadRoutines - Fetched 5 routines from DB
   ✅ loadRoutines - Updated routines to 0 items  ← 문제!
   ```

3. **로그가 아예 안 나오는 경우**
   - deleteRoutine() 함수가 호출되지 않음
   - UI 연결 문제

## 5️⃣ 로그 필터링

콘솔 창 하단의 **검색창** 사용:

- `🗑️` 입력 → 삭제 관련만
- `📥` 입력 → 로드 관련만
- `Error` 입력 → 에러만
- `Delete` 입력 → Delete 관련만

## 6️⃣ 콘솔 로그 복사하기

1. 콘솔에서 텍스트 드래그 선택
2. **Cmd + C** 복사
3. 메모장이나 Claude에게 붙여넣기

## 7️⃣ 문제 해결 팁

### 콘솔이 아예 안 보이는 경우:

```
Cmd + 0    - Navigator 숨기기/보이기
Cmd + Opt + 0  - Inspector 숨기기/보이기
Cmd + Shift + Y - Debug Area 숨기기/보이기 ← 이것!
```

### 로그가 너무 많아서 찾기 어려운 경우:

1. **콘솔 지우기**:
   - 콘솔 우측 상단 🗑️ (휴지통) 아이콘 클릭

2. **테스트 다시 실행**:
   - 앱에서 루틴 삭제
   - 깨끗한 콘솔에서 로그 확인

3. **특정 로그만 필터**:
   - 검색창에 이모지 입력

## 8️⃣ 스크린샷 찍기

로그를 보여주고 싶다면:

1. **콘솔 창 클릭**
2. **Cmd + Shift + 4** (영역 캡처)
3. 콘솔 부분 드래그
4. 이미지가 바탕화면에 저장됨

---

## 빠른 체크리스트

- [ ] Xcode 프로젝트 열림
- [ ] Cmd + Shift + Y 눌러서 디버그 영역 표시
- [ ] 하단에 콘솔 보임
- [ ] Cmd + R로 앱 실행
- [ ] 시뮬레이터에서 루틴 삭제
- [ ] 콘솔에 🗑️ 이모지 로그 보임
- [ ] 로그 복사해서 확인

---

**도움이 필요하면:**
- 콘솔 로그를 복사해서 Claude에게 보내주세요
- 또는 스크린샷을 찍어서 보내주세요
