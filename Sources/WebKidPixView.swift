#if KIDPAD_FIDELITY_DEV
import SwiftUI
import WebKit
import os

/// Opt-in local comparison harness for the pinned JSKidPix HTML/JS bundle.
/// Normal launch uses WorkspaceView; pass `--reference-web` to load this WKWebView.
struct WebKidPixView: UIViewRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("JSON.stringify({init:typeof init_kiddo_paint, color:document.getElementById('currentColor')?.getAttribute('style'), canvas:document.getElementById('kiddopaint')?.width, error:document.documentElement.getAttribute('data-jskidpix-error')})") { value, error in
                let logger = Logger(subsystem: "com.chrissotraidis.kidpad", category: "JSKIDPIX")
                if let error { logger.error("JSKIDPIX_WEB_ERROR: \(String(describing: error))") }
                else { logger.notice("JSKIDPIX_WEB_STATE: \(String(describing: value))") }
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController.addUserScript(WKUserScript(source: "window.onerror=function(message){document.documentElement.setAttribute('data-jskidpix-error', String(message));};", injectionTime: .atDocumentStart, forMainFrameOnly: true))
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.backgroundColor = .white
        view.isOpaque = true
        view.scrollView.isScrollEnabled = false
        view.navigationDelegate = context.coordinator
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "JSKidPix") {
            view.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) { }
}
#endif
