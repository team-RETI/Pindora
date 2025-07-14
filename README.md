<div align=center>

# 📍 Pindora
### **처음 가는 곳에서도, 사용자의 취향을 찾아주는 장소 추천 서비스**
사용자의 위치와 취향을 기반으로, 낯선 도시에서도 어울리는 공간을 찾아드립니다.

</div>

## 📚 Git 컨벤션 가이드

### 🔀 Branch Convention
1. **기본 브랜치 설정**
- develop: 기능을 개발하는 브랜치

2. **작업 순서**
    1. 작업할 이슈 생성
    2. 적합한 Label 할당 후 Assignee 본인 할당
    3. 자동 생성된 브랜치(ex: `feature/#163`)에서 작업 수행
    4. 원격 저장소에 작업 브랜치 푸시
    5. Pull Request 생성
        - develop 브랜치를 대상으로 Pull Request 생성
        - 과반수 이상의 리뷰어의 리뷰를 받은 후 PR 승인을 받고 `develop` 브랜치에 자동 병합

### 💬 Commit Convention
```swift
// Format
[#Issue Number]: Description

// Xcode에서 커밋 Example
[#163]: 로그인 기능 구현
```

### 🍎 Code Convention
[📖RETIA Code Convention📖](https://github.com/team-RETI/Pindora/blob/develop/CodeConvention.md)  

네이밍 규칙
- 변수/상수: 카멜케이스 (ex: `groupName`)
- 클래스/구조체: 파스칼케이스 (ex: `LoginView`)
- 함수/메서드: 동사로 시작하며 카멜케이스 (ex: fetchData())

코드 스타일
- 명시적 타입 선언: 타입을 명시적으로 선언합니다 (ex: `var groupName: String = "RETIA"`)
- 옵셔널 처리: 런타입 에러를 방지하기 위해 강제 언래핑(!)을 사용하지 않고 `guard let`, `if let`, `옵셔널 체이닝`을 사용합니다.
- private: 가능한 class에서 사용되는 property는 모두 private로 선언합니다. 
- final: 성능 최적화를 위해 더 이상 상속되지 않는 class에는 꼭 final 키워드를 붙입니다.


## 🚀 Getting Started
공개하지 않아야 하는 파일들은 Private 레포지토리에 있으며, 이 저장소에 초대된 팀원이라면 **명령어 한 줄로 전체 환경을 자동 구성할 수 있습니다.**

### ✅ `make` 명령어로 자동 구성되는 항목
- `.env`, `Config.xcconfig` 등의 설정 파일 자동 다운로드  
- 필수 개발 도구 설치: `Homebrew`, `SwiftLint`, `Fastlane`  
- 인증서 다운로드: `Fastlane Match`를 통해 `Provisioning Profile` 및 인증서 자동 설정  

> 🔐 **주의:** 최초 1회 실행 시 아래 **2가지 인증 정보 입력이 필요**합니다.  
> 1. **GitHub Personal Access Token** – private 파일 다운로드 용도  
> 2. **Fastlane Match 암호 (MATCH_PASSWORD)** – 인증서 복호화 용도  
> 👉 두 정보 모두 팀 노션에 공유되어 있습니다.

### 💻 실행 방법
```bash
# 프로젝트 루트 경로에서 터미널을 열고 아래 명령어를 입력하세요
make
```
