//
//  ShareViewController.swift
//  PindoraShareExtension
//
//  Created by 김동현 on 7/18/25.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extractSharedURL()
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        
        // MARK: - 사용자가 "공유" 누른 후 호출됨
        // ✅ 사용자 입력 텍스트 출력
        if let text = contentText, !text.isEmpty {
            print("✅ 공유된 텍스트: \(text)")
        }
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}

extension ShareViewController {
    private func extractSharedURL() {
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else { return }
        for item in extensionItems {
            guard let attachments = item.attachments else { continue }
            
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier("public.url") {
                    provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (data, error) in
                        if let url = data as? URL {
                            print("✅ 공유된 URL: \(url.absoluteString)")
                        } else if let str = data as? String {
                            print("✅ 공유된 문자열 URL: \(str)")
                        } else {
                            print("⚠️ URL을 가져올 수 없습니다.")
                        }
                    }
                }
            }
        }
    }
}
