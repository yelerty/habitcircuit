# Habit Circuit - iOS 습관 관리 앱

요일별로 자신만의 루틴(습관 회로)을 만들고, 각 루틴을 순서대로 수행하는 iOS 전용 자기계발 앱입니다.

## 핵심 기능

### 1. 순차적 루틴 실행
- 루틴은 순차적으로 연결된 회로 구조로 작동합니다
- 현재 루틴을 완료해야 다음 루틴이 활성화됩니다
- 모든 루틴 완료 시 완료 화면이 표시됩니다

### 2. 요일별 루틴 관리
- 월요일부터 일요일까지 각 요일마다 별도의 루틴 세트를 관리할 수 있습니다
- 상단 요일 선택 탭으로 쉽게 전환 가능합니다

### 3. 직관적인 UI/UX
- **홈 화면**: 오늘의 루틴 목록과 진행 상황 확인
- **실행 화면**: 현재 수행 중인 루틴만 표시되어 집중력 향상
- **편집 화면**: 드래그 앤 드롭으로 루틴 순서 조정

### 4. 로컬 데이터 저장
- Core Data를 사용한 완전한 오프라인 기능
- 서버 연결 불필요, 개인정보 보호

## 프로젝트 구조

```
HabitCircuit/
├── HabitCircuit/
│   ├── HabitCircuitApp.swift          # 앱 진입점
│   ├── Persistence.swift              # Core Data 설정
│   │
│   ├── Models/
│   │   ├── DayOfWeek.swift           # 요일 enum
│   │   └── RoutineItem.swift         # 루틴 데이터 모델
│   │
│   ├── ViewModels/
│   │   └── RoutineViewModel.swift    # MVVM 뷰모델
│   │
│   ├── Views/
│   │   ├── ContentView.swift         # 메인 컨테이너
│   │   ├── HomeView.swift            # 홈 화면
│   │   ├── RoutineExecutionView.swift # 루틴 실행 화면
│   │   └── RoutineEditView.swift     # 루틴 편집 화면
│   │
│   └── HabitCircuit.xcdatamodeld/    # Core Data 모델
└── HabitCircuit.xcodeproj/
```

## 기술 스택

- **언어**: Swift
- **UI 프레임워크**: SwiftUI
- **데이터베이스**: Core Data
- **아키텍처**: MVVM (Model-View-ViewModel)
- **최소 iOS 버전**: iOS 15.0+

## 데이터 모델

### Routine Entity
- `id`: UUID - 고유 식별자
- `name`: String - 루틴 이름
- `order`: Int16 - 순서
- `dayOfWeek`: String - 요일
- `isCompleted`: Bool - 완료 여부
- `createdAt`: Date - 생성 일시

## 설치 및 실행

### 1. Xcode에서 프로젝트 열기
```bash
cd HabitCircuit
open HabitCircuit.xcodeproj
```

### 2. 시뮬레이터 또는 실제 기기에서 실행
- Xcode에서 타겟 기기를 선택합니다
- Command + R 키를 누르거나 Run 버튼을 클릭합니다

### 3. 프로젝트 빌드
```bash
# Command Line에서 빌드하려면:
xcodebuild -project HabitCircuit.xcodeproj -scheme HabitCircuit -configuration Debug
```

## 사용 방법

### 루틴 추가하기
1. 홈 화면 우측 상단의 '+' 버튼을 탭합니다
2. 텍스트 필드에 루틴 이름을 입력합니다
3. '+' 버튼을 눌러 루틴을 추가합니다

### 루틴 순서 변경하기
1. 편집 화면에서 'Edit' 버튼을 탭합니다
2. 루틴을 드래그하여 원하는 순서로 배치합니다
3. '완료' 버튼을 탭합니다

### 루틴 실행하기
1. 홈 화면에서 '루틴 시작' 버튼을 탭합니다
2. 현재 루틴이 표시됩니다
3. 루틴을 완료한 후 '완료' 버튼을 탭합니다
4. 다음 루틴이 자동으로 표시됩니다
5. 모든 루틴을 완료하면 완료 화면이 나타납니다

### 요일 변경하기
- 상단의 요일 탭을 탭하여 다른 요일의 루틴을 확인하거나 편집할 수 있습니다

## 주요 기능 설명

### 1. 순차적 실행 로직
- 현재 인덱스를 추적하여 활성 루틴을 관리합니다
- 완료된 루틴은 회색으로 표시되고 비활성화됩니다
- 미완료 루틴 중 첫 번째 루틴만 활성화됩니다

### 2. 진행률 표시
- 원형 프로그레스 바로 전체 진행률을 시각화합니다
- "n/total 완료" 형식으로 정확한 진행 상황을 표시합니다

### 3. 데이터 영속성
- Core Data를 통해 모든 루틴 데이터를 로컬에 저장합니다
- 앱을 종료해도 데이터가 유지됩니다

## 향후 개선 사항

- [ ] 일일 알림 기능 (리마인더)
- [ ] 완료 통계 및 그래프
- [ ] 루틴 템플릿 공유 (AirDrop)
- [ ] AI 코칭 (루틴 패턴 분석)
- [ ] 위젯 지원
- [ ] 다크 모드 최적화

## 라이선스

이 프로젝트는 개인 학습 및 포트폴리오 목적으로 작성되었습니다.

## 연락처

문의 사항이 있으시면 이슈를 등록해주세요.
