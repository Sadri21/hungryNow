//
//  ScrollOffsetTracker.swift
//  hungrynow
//
//  A reusable, zero-overhead scroll offset observer for SwiftUI ScrollViews.
//  Uses KVO directly on the underlying UIScrollView's `contentOffset` to ensure
//  smooth 120Hz updates across all iOS versions (iOS 16 through iOS 26+) without
//  relying on throttled SwiftUI preference keys.
//

import SwiftUI
import UIKit

/// A lightweight `UIViewRepresentable` that attaches an observer to the enclosing `UIScrollView`.
public struct ScrollOffsetTracker: UIViewRepresentable {
    private let onOffsetChange: (CGFloat) -> Void

    public init(onOffsetChange: @escaping (CGFloat) -> Void) {
        self.onOffsetChange = onOffsetChange
    }

    public func makeUIView(context: Context) -> OffsetTrackerView {
        let view = OffsetTrackerView()
        view.onOffsetChange = onOffsetChange
        return view
    }

    public func updateUIView(_ uiView: OffsetTrackerView, context: Context) {
        uiView.onOffsetChange = onOffsetChange
    }
}

public final class OffsetTrackerView: UIView {
    var onOffsetChange: ((CGFloat) -> Void)?
    private var observation: NSKeyValueObservation?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        attachObserver()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        attachObserver()
    }

    private func attachObserver() {
        guard observation == nil else { return }
        var current: UIView? = self
        while let parent = current?.superview {
            if let sv = parent as? UIScrollView {
                observation = sv.observe(\.contentOffset, options: [.initial, .new]) { [weak self] scrollView, _ in
                    guard let self = self else { return }
                    let actualOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
                    DispatchQueue.main.async {
                        self.onOffsetChange?(actualOffset)
                    }
                }
                break
            }
            current = parent
        }
    }

    deinit {
        observation?.invalidate()
    }
}

// MARK: - View Extension

extension View {
    /// Tracks the vertical scroll offset of the nearest ancestor `UIScrollView`.
    /// - Parameter onOffsetChange: Callback delivering the actual scroll offset in points (0 at top rest).
    public func trackScrollOffset(_ onOffsetChange: @escaping (CGFloat) -> Void) -> some View {
        background(ScrollOffsetTracker(onOffsetChange: onOffsetChange))
    }
}
