<div align=center>

# 📍 Pindora
### **처음 가는 곳에서도, 사용자의 취향을 찾아주는 장소 추천 서비스**
사용자의 위치와 취향을 기반으로, 낯선 도시에서도 어울리는 공간을 찾아드립니다.

</div>

## 📚 Convention

## 🔀 Branch Convention
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

## 💬 Commit Convention
```swift
// Format
[#Issue Number]: Description

// Xcode에서 커밋 Example
[#163]: 로그인 기능 구현
```
