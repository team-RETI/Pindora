# 컨벤션
컨벤션(Convention)은 팀원들이 코드를 일관성 있게 작성하고 유지보수하기 쉽게 만들기 위한 코딩 규칙과 스타일 가이드입니다.   

# 네이밍

## 변수
- 변수 이름은 `lowerCamelCase`를 사용해주세요.
```swift
var groupName: String = "RETIA"
```

## 함수
- 함수 이름은 `lowerCamelCase`를 사용해주세요.
- 함수는 일반적으로 동사원형으로 시작해주세요.
- 데이터를 가져오는 함수인 경우 `get` 사용을 지양하고 `fetch`를 사용해주세요.
```swift
func fetchData() {}
```

## 열거형
- 열거형의 이름은 `UpperCamelCase`를 사용해주세요.
- 열거형의 각 case에는 `lowerCamelCase`를 사용해주세요.
```swift
enum Result {
    case .success
    case .failure
}
```

# 주석

## 문서화 주석
- 프로토콜에서는 무조건 Swift 문서화 주석 형식을 사용해주세요.
- 문서화 주석 단축키: command[⌘] + option[⌥] + [/]
```swift
/// 사용자의 프로필을 업데이트합니다.
///
/// - Parameter name: 새 사용자 이름
/// - Parameter age: 새 사용자 나이
/// - Returns: 업데이트 성공 여부를 반환합니다.
func updateProfile(name: String, age: Int) -> Bool {
    // ...
    return true
}
```

# 스타일

## 들여쓰기 & 띄어쓰기
- 인텐트는 스페이스바 4개로 통일해주세요.(탭1 = 스페이스바4)
```swift
func fetchData() {
    print("hello world")
}
```

## 후행 클로저
- 인자가 한 개일 경우에만 $0를 허용하고, 복잡한 로직 또는 가독성이 떨어질 경우 명시적으로 `element in` 같은 이름을 사용합니다.
```swift
let retia = ["Ray", "Evan", "Triple", "Index", "Alex"].map { $0.lowercased() }
```

## 옵셔널
- 강제 언래핑 (`!`) 은 절대 사용하지 않습니다.
- 옵셔널 바인딩 (`if let`, `guard let`) 또는 nil-coalescing(`??`)를 사용해주세요.

# UIKit

## ViewController 선언
- 성능 최적화를 위해 더 이상 상속되지 않는 class에는 꼭 final 키워드를 붙입니다.
- 가능한 class에서 사용되는 property는 모두 private로 선언합니다.
- 하나의 파일 이내에서 `UIView`, `UIViewController`, `UITableViewCell` 등에서 뷰 계층을 구분하는 경우
- 구조체나 클래스로 나눌 경우: `// MARK: -(S)` 사용
- 메서드형 UI 구성 요소: `// MARKL \(F)` 사용
```swift
import UIKit

// MARK: - (S)ProfileViewController
final class ProfileViewController: UIViewController {

    // MARK: UI
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "홍길동"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        return button
    }()

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    // MARK: (F)setupUI
    private func setupUI() {
        [nameLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),

            logoutButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
    }

    // MARK: (F)didTapLogout
    @objc private func didTapLogout() {
        print("로그아웃 버튼 탭됨")
    }
}

```
