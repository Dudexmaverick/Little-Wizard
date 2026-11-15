import Gtk
import CGtk
import Foundation

final class InventoryClick {
    private let onClick: (Double, Double) -> Void

    init(
        area: DrawingAreaRef,
        onClick: @escaping (Double, Double) -> Void
    ) {
        self.onClick = onClick

        guard let gesture = gtk_gesture_click_new() else {
            return
        }

        let userData = Unmanaged.passRetained(self).toOpaque()

        "pressed".withCString { signal in
            _ = g_signal_connect_data(
                gesture,
                signal,
                unsafeBitCast(
                    InventoryClick.pressed,
                    to: GCallback.self
                ),
                userData,
                { data, _ in
                    guard let data else { return }

                    Unmanaged<InventoryClick>
                        .fromOpaque(data)
                        .release()
                },
                GConnectFlags(rawValue: 0)
            )
        }

        gtk_widget_add_controller(
            area.ptr.assumingMemoryBound(to: GtkWidget.self),
            UnsafeMutableRawPointer(gesture)
                .assumingMemoryBound(to: GtkEventController.self)
        )
    }

    private static let pressed:
        @convention(c) (
            UnsafeMutableRawPointer?,
            Int32,
            Double,
            Double,
            UnsafeMutableRawPointer?
        ) -> Void = { _, _, x, y, data in

            guard let data else { return }

            let controller = Unmanaged<InventoryClick>
                .fromOpaque(data)
                .takeUnretainedValue()

            controller.onClick(x, y)
        }
}
