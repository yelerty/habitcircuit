Habit Circuit - iOS MVP Design Document
1. App Overview

Goal:
사용자가 요일별로 자신만의 루틴(습관 회로)을 만들고, 각 루틴을 순서대로 수행해야 다음 단계로 진행할 수 있는 iOS 전용 자기계발 앱.

Core Concept:

루틴은 순차적 연결(회로 구조) 로 작동한다.

루틴 완료 전까지 다음 루틴은 비활성 상태(hidden).

요일마다 다른 루틴 구성이 가능하다.

모든 데이터는 로컬 저장 (Core Data or SQLite).

2. Core Features (MVP Scope)

요일별 루틴 생성 및 편집

Drag & Drop 으로 순서 조정

간단한 입력 UI (텍스트 입력 → 추가 버튼)

루틴 삭제 및 수정 기능

루틴 실행 화면

현재 수행 중인 루틴만 표시

"완료" 버튼 클릭 시 다음 루틴 활성화

루틴 완료 시 전체 요약 화면 표시

요일별 관리

상단에서 요일 선택 (월~일)

각 요일마다 별도의 루틴 세트 보관

데이터 저장

Core Data(Entity: Routine, Day)

모든 데이터는 로컬에 저장되어 서버 불필요

간단한 통계 (선택적)

각 요일별 완료율 %

최근 7일 루틴 완료 그래프 (Bar Chart)

3. Screen Flow
1️⃣ Home Screen

상단: “오늘 요일” 표시 + 요일 전환 탭

중앙: 오늘 루틴 목록 (비활성 루틴은 흐리게 표시)

하단: “루틴 실행 시작” 버튼

2️⃣ Routine Execution Screen

현재 루틴 이름 크게 표시

진행률 바 (예: 2/7 완료)

“완료” 버튼 → 다음 루틴 표시

3️⃣ Routine Edit Screen

루틴 추가 TextField

루틴 리스트 (삭제, 순서 변경 가능)

저장 버튼

4. Data Model Example
Entity: Routine
- id: UUID
- name: String
- order: Int16
- dayOfWeek: String  // e.g., "Monday"
- isCompleted: Bool

5. Local Logic Flow
User taps “Start Routine” →
  Load routines for selected day →
    Show first incomplete routine →
      OnComplete → unlock next routine →
        After all done → show “All Done” summary

6. Technical Stack

Language: Swift / SwiftUI

Database: CoreData

Architecture: MVVM

Persistence: UserDefaults (settings), CoreData (routines)

No server, fully offline

7. MVP Development Priority

Routine CRUD (Create/Read/Update/Delete)

Sequential execution logic

UI (3 main screens)

Local data persistence

Optional: daily notification (리마인더)

8. Future Expansion Ideas

AI 코칭: 루틴 패턴 분석 후 제안

루틴 공유 (AirDrop으로)