//
//  LocationUseCaseProtocol.swift
//  Pindora
//
//  Created by eunchanKim on 8/31/25.
//

import Foundation
import Combine
import CoreLocation

/// 위치 권한 및 위치 업데이트를 담당하는 유즈케이스
///
/// - 이 레이어의 목적
///   - `CLLocationManager`(인프라/SDK 디테일)를 ViewModel/뷰에서 분리해 **비즈니스 규칙 중심의 인터페이스**만 노출.
///   - 퍼블리셔(스트림) 기반으로 권한/위치 변화를 **실시간 반응형**으로 전달.
///   - 테스트 시에는 이 프로토콜만 목/스텁으로 갈아끼워 **테스트 용이성** 확보.
///
/// - 설계 포인트
///   - 퍼블리셔는 `AnyPublisher`로 타입을 지워 구체 구현(Subject 사용 여부, 스케줄러 등)을 캡슐화.
///   - 실패 타입을 `Never`로 고정하여, 권한 거부/실패 상황은 별도 경로(예: 상태/도메인 에러 스트림)로 표현.
///   - start/stop 제어를 분리해 **배터리/프라이버시**를 고려한 구독 수명 관리가 가능.
///   - 즉시 판단이 필요한 곳(권한 가드, 플로우 분기)은 `ensureLocationAuthorized` 같은 **동기적 사고에 맞춘 API** 제공.
protocol LocationUseCaseProtocol {

    // Streams (읽기 전용 상태 스트림)
    
    /// 위치 **권한 상태**를 스트리밍하는 퍼블리셔
    ///
    /// - 왜 필요한가?
    ///   - iOS의 위치 권한은 "요청 → 즉시 허용/거부"가 아니라, **사용자 상호작용/설정 앱 이동** 등으로
    ///     상태가 비동기적으로 변하며, 앱 포그라운드/백그라운드 전환에 따라 재평가가 필요.
    ///   - UI는 이 스트림을 구독해 권한 상태 변화에 **즉각 반응**(권한 가이드, 설정 이동 버튼 노출 등).
    ///
    /// - 설계 메모
    ///   - `CLAuthorizationStatus`를 그대로 노출하는 이유는 ***권한 세분화***(.notDetermined / .denied / .restricted /
    ///     .authorizedWhenInUse / .authorizedAlways 등)에 맞춰 뷰 로직을 세밀하게 구성하기 위함.
    ///   - 실패 타입을 `Never`로 둔 이유는, **권한 자체는 실패 개념보다는 상태(state)**이기 때문.
    ///     권한 거부도 "실패"가 아니라 유효한 하나의 상태로 간주.
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }

    /// **위치 업데이트**를 스트리밍하는 퍼블리셔
    ///
    /// - 왜 필요한가?
    ///   - 지도 중심 이동, 거리순 정렬, 내 주변 검색 등은 **연속적인 위치 변화**에 즉시 반응해야 한다.
    ///   - 사용자가 이동할 수 있고, iOS는 배터리/정확도 정책에 따라 간헐적으로 값을 보냄 → 스트림이 자연스러움.
    ///
    /// - 설계 메모
    ///   - 실패 타입을 `Never`로 둔 이유: 위치 업데이트 실패는 보통 "일시적 네트워크/하드웨어/권한 문제"로,
    ///     스트림 자체를 종료시키기보다는 별도 에러 채널(예: `UseCaseError` 퍼블리셔)로 전파하는 편이 UX가 안정적.
    ///   - 최신 위치만 쓰는 경우, ViewModel에서 `throttle`, `debounce`, `removeDuplicates` 등을 적용해
    ///     **배터리/성능 최적화** 가능.
    var locationPublisher: AnyPublisher<CLLocation, Never> { get }

    // Commands (명령형 트리거)

    /// 위치 **권한 요청** (보통 최초 실행 시 사용)
    ///
    /// - 왜 필요한가?
    ///   - iOS는 **명시적 트리거** 없이 권한 알럿을 띄우지 않는다. 사용자가 "내 위치 보기"를 누르는 등
    ///     **행동의 맥락**에서 권한을 요청해야 UX가 자연스럽다.
    ///   - 권한 요청 후의 결과는 즉시 반환되지 않으므로, `authorizationStatusPublisher` 구독을 통해
    ///     후속 플로우를 이어간다.
    ///
    /// - 사용 예
    ///   - "거리순" 필터를 탭했을 때 권한이 없으면 이 함수를 호출 → 이후 상태 스트림 변화에 맞춰 UI 업데이트.
    func requestAuthorization()

    /// **위치 업데이트 시작**
    ///
    /// - 왜 필요한가?
    ///   - 위치 스트림은 배터리를 소모한다. **필요할 때만** 시작하여 수명 관리가 필수.
    ///   - 예: 맵 화면 진입 시 시작, 떠날 때 중지. 또는 내 위치 버튼 탭 시 일시적으로 시작.
    ///
    /// - 설계 메모
    ///   - 내부적으로 `CLLocationManager.startUpdatingLocation()` / 필요 시 `startMonitoringSignificantLocationChanges()`
    ///     등 정책 전환을 숨기고, 유즈케이스 수준에서는 **의도(시작/중지)**만 표현.
    func startUpdatingLocation()

    /// **위치 업데이트 중지**
    ///
    /// - 왜 필요한가?
    ///   - 맵 화면에서 벗어났거나, 더 이상 내 위치가 필요하지 않을 때 **즉시 중지**해야
    ///     배터리/프라이버시 모두를 지킬 수 있다.
    ///
    /// - 설계 메모
    ///   - 구독 기반 구조(Combine)에서는 ViewModel이 화면 라이프사이클에 맞춰 이 타이밍을 제어.
    func stopUpdatingLocation()

    // Guards (플로우 분기/가드에 최적화된 도우미)

    /// 위치 권한이 있는지 **검사**하고, 콜백으로 결과 반환
    ///
    /// - 왜 필요한가?
    ///   - 일부 플로우는 "권한이 있으면 바로 A로, 없으면 B로"처럼 **즉시 분기**가 필요.
    ///   - 퍼블리셔/구독을 깔고 기다리기보다는, **한 번 평가**로 Bool 결과만 받는 편이 간편한 경우가 많다.
    ///
    /// - 동작 기대
    ///   - 현재 권한 상태(예: `.authorizedWhenInUse` 또는 `.authorizedAlways`)면 `true`,
    ///     그 외(`.notDetermined`, `.denied`, `.restricted`)면 `false`를 콜백.
    ///   - 아직 요청하지 않은 상태라면, 이 함수에서 **요청을 트리거하지는 않음**(명령은 `requestAuthorization()`의 책임).
    ///     → 가드와 명령의 역할을 분리하여 **부수효과(Side Effect) 없는 판별자**로 유지.
    ///
    /// - 대안/확장
    ///   - 동일 목적의 **Publisher 버전**(e.g. `ensureLocationAuthorizedPublisher() -> AnyPublisher<Bool, Never>`)
    ///     을 함께 제공하면 리액티브 체인에서 더 깔끔하게 쓸 수 있다.
    func ensureLocationAuthorized(_ completion: @escaping (Bool) -> Void)
}

