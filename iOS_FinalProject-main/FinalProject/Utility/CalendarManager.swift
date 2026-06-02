import EventKit
import Foundation

final class CalendarManager {
    static let shared = CalendarManager()
    private nonisolated(unsafe) let ekStore = EKEventStore()

    func requestAccess() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .fullAccess:
            return true
        case .denied, .restricted:
            throw CalendarError.accessDenied
        default:
            return try await ekStore.requestFullAccessToEvents()
        }
    }

    func addEvent(title: String, date: Date, note: String?) async throws {
        guard try await requestAccess() else {
            throw CalendarError.accessDenied
        }
        let event = EKEvent(eventStore: ekStore)
        event.title = title
        event.startDate = date
        event.endDate = date.addingTimeInterval(3600)
        event.notes = note
        event.calendar = ekStore.defaultCalendarForNewEvents
        try ekStore.save(event, span: .thisEvent)
    }

    enum CalendarError: LocalizedError {
        case accessDenied
        var errorDescription: String? {
            "行事曆存取被拒絕，請至「設定」>「隱私權與安全性」>「行事曆」中開啟存取權限。"
        }
    }
}
