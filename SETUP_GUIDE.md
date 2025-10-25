# Habit Circuit - 프로젝트 설정 가이드

## Xcode에서 프로젝트 열기

현재 프로젝트는 Swift/SwiftUI로 작성된 iOS 앱입니다. Xcode에서 프로젝트를 열어 사용하실 수 있습니다.

### 방법 1: Xcode에서 직접 열기
1. Xcode를 실행합니다
2. "Open a project or file" 선택
3. `HabitCircuit/HabitCircuit.xcodeproj` 파일을 선택합니다

### 방법 2: 터미널에서 열기
```bash
cd /Users/jihong/code/apps/habitcircuit
open HabitCircuit/HabitCircuit.xcodeproj
```

## 프로젝트 빌드 및 실행

### 1. 타겟 선택
- Xcode 상단의 타겟 선택 메뉴에서 원하는 시뮬레이터를 선택합니다
- 권장: iPhone 14 Pro 또는 iPhone 15 Pro 시뮬레이터

### 2. 빌드 설정 확인
프로젝트를 처음 열면 다음 설정들을 확인해야 합니다:

1. **Signing & Capabilities** 탭에서:
   - Team 선택 (개인 Apple ID로 로그인 가능)
   - Bundle Identifier 설정 (예: com.yourname.habitcircuit)

2. **General** 탭에서:
   - Deployment Target: iOS 15.0 이상
   - Display Name: Habit Circuit

### 3. 실행
- Command + R 키를 누르거나
- Xcode 상단의 ▶ (Play) 버튼을 클릭합니다

## 파일 구조 설명

```
HabitCircuit/
├── HabitCircuit/                      # 메인 앱 폴더
│   ├── HabitCircuitApp.swift         # 앱 진입점 (@main)
│   ├── Persistence.swift             # Core Data 컨트롤러
│   ├── Info.plist                    # 앱 설정 파일
│   │
│   ├── Models/                       # 데이터 모델
│   │   ├── DayOfWeek.swift          # 요일 열거형
│   │   └── RoutineItem.swift        # 루틴 아이템 구조체
│   │
│   ├── ViewModels/                   # 뷰 모델 (MVVM)
│   │   └── RoutineViewModel.swift   # 루틴 로직 관리
│   │
│   ├── Views/                        # UI 화면
│   │   ├── ContentView.swift        # 메인 컨테이너
│   │   ├── HomeView.swift           # 홈 화면
│   │   ├── RoutineExecutionView.swift # 실행 화면
│   │   └── RoutineEditView.swift    # 편집 화면
│   │
│   └── HabitCircuit.xcdatamodeld/   # Core Data 모델
│       └── HabitCircuit.xcdatamodel/
│           └── contents             # Entity 정의
│
└── HabitCircuit.xcodeproj/          # Xcode 프로젝트 파일
    └── project.pbxproj              # 프로젝트 설정
```

## 주요 화면 설명

### 1. HomeView (홈 화면)
- 요일 선택 탭 바
- 오늘의 루틴 목록
- 진행 상황 프로그레스 바
- 루틴 시작/다시 시작 버튼
- 루틴 추가 버튼 (+)

**파일 위치**: `HabitCircuit/HabitCircuit/Views/HomeView.swift`

### 2. RoutineExecutionView (실행 화면)
- 원형 진행률 표시기
- 현재 루틴 이름 (크게 표시)
- 완료 버튼
- 완료 시 축하 화면

**파일 위치**: `HabitCircuit/HabitCircuit/Views/RoutineExecutionView.swift`

### 3. RoutineEditView (편집 화면)
- 루틴 추가 텍스트 필드
- 드래그 앤 드롭으로 순서 변경
- 루틴 이름 편집
- 루틴 삭제

**파일 위치**: `HabitCircuit/HabitCircuit/Views/RoutineEditView.swift`

## Core Data 모델

### Routine Entity
Entity 이름: `Routine`

| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID | 고유 식별자 |
| name | String | 루틴 이름 |
| order | Int16 | 순서 (0부터 시작) |
| dayOfWeek | String | 요일 (예: "월요일") |
| isCompleted | Bool | 완료 여부 |
| createdAt | Date | 생성 날짜 |

**파일 위치**: `HabitCircuit/HabitCircuit/HabitCircuit.xcdatamodeld/`

## ViewModel 로직

`RoutineViewModel`은 다음 기능들을 제공합니다:

- `loadRoutines()`: 선택된 요일의 루틴 불러오기
- `addRoutine(name:)`: 새 루틴 추가
- `deleteRoutine(at:)`: 루틴 삭제
- `moveRoutine(from:to:)`: 루틴 순서 변경
- `updateRoutine(id:newName:)`: 루틴 이름 수정
- `completeCurrentRoutine()`: 현재 루틴 완료 처리
- `resetDailyRoutines()`: 모든 루틴 초기화

**파일 위치**: `HabitCircuit/HabitCircuit/ViewModels/RoutineViewModel.swift`

## 앱 기능 테스트

### 테스트 시나리오 1: 루틴 추가
1. 앱 실행
2. 우측 상단 '+' 버튼 탭
3. "아침 운동" 입력 후 '+' 버튼 탭
4. "명상 10분" 입력 후 '+' 버튼 탭
5. "독서 30분" 입력 후 '+' 버튼 탭
6. '완료' 버튼으로 홈 화면 복귀

### 테스트 시나리오 2: 루틴 실행
1. 홈 화면에서 "루틴 시작" 버튼 탭
2. 첫 번째 루틴 확인 ("아침 운동")
3. "완료" 버튼 탭
4. 두 번째 루틴 확인 ("명상 10분")
5. "완료" 버튼 탭
6. 세 번째 루틴 확인 ("독서 30분")
7. "완료" 버튼 탭
8. 완료 화면 확인

### 테스트 시나리오 3: 루틴 순서 변경
1. 홈 화면에서 '+' 버튼 탭
2. 'Edit' 버튼 탭
3. 루틴을 드래그하여 순서 변경
4. 'Done' 버튼 탭
5. '완료' 버튼으로 홈 화면 복귀
6. 변경된 순서 확인

## 문제 해결

### 빌드 에러 발생 시
1. Xcode를 재시작합니다
2. Product > Clean Build Folder (Command + Shift + K)
3. 다시 빌드합니다 (Command + B)

### Core Data 에러 발생 시
1. 시뮬레이터의 앱을 삭제합니다
2. 시뮬레이터를 재시작합니다
3. 앱을 다시 빌드하고 실행합니다

### Signing 에러 발생 시
1. Xcode > Preferences > Accounts에서 Apple ID 추가
2. 프로젝트 설정 > Signing & Capabilities에서 Team 선택
3. Bundle Identifier를 고유한 값으로 변경 (예: com.yourname.habitcircuit)

## 다음 단계

프로젝트가 정상적으로 실행되면 다음과 같은 개선 작업을 진행할 수 있습니다:

1. **UI 개선**
   - 커스텀 색상 테마 추가
   - 애니메이션 효과 강화
   - 다크 모드 최적화

2. **기능 추가**
   - 일일 알림 (UserNotifications)
   - 통계 화면 (Charts framework)
   - 루틴 템플릿 공유

3. **테스트 작성**
   - Unit Tests 추가
   - UI Tests 추가

4. **최적화**
   - 메모리 사용량 최적화
   - 애니메이션 성능 개선

## 도움이 필요하신가요?

프로젝트 관련 질문이나 문제가 있으시면:
1. Xcode의 이슈 네비게이터 확인 (Command + 8)
2. 빌드 로그 확인
3. README.md 파일의 향후 개선 사항 참고

즐거운 코딩 되세요! 🚀
