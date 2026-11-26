// NextMeeting: writes the current/next calendar event to a cache file for
// SketchyBar's meeting item. Reads macOS Calendar (EventKit), so the Outlook
// account must be added under System Settings > Internet Accounts.
//
// It is a (windowless) .app rather than a plain binary because macOS only
// grants calendar access to apps with a usage description; a binary run by
// sketchybar would be denied without a prompt. plugins/meeting.sh launches it
// with `open -g -j` and reads the file it writes:
//
//   ~/Library/Caches/sketchybar/next_meeting.tsv
//     "<title>\t<start epoch>\t<end epoch>"  an event to show
//     ""                                     nothing left today
//     "!denied"                              no calendar permission
//
// Build: helpers/next_meeting/build.sh

import EventKit
import Foundation

let outDir = FileManager.default.homeDirectoryForCurrentUser
  .appendingPathComponent("Library/Caches/sketchybar")
let outFile = outDir.appendingPathComponent("next_meeting.tsv")

func write(_ s: String) {
  try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
  try? s.write(to: outFile, atomically: true, encoding: .utf8)
}

let store = EKEventStore()
let done = DispatchSemaphore(value: 0)
var granted = false
store.requestFullAccessToEvents { ok, _ in granted = ok; done.signal() }
done.wait()

guard granted else { write("!denied"); exit(0) }

let now = Date()
let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
let calendars = store.calendars(for: .event).filter {
  $0.type != .subscription && $0.type != .birthday  // holidays, birthdays
}
let predicate = store.predicateForEvents(
  withStart: now.addingTimeInterval(-12 * 3600), end: endOfDay, calendars: calendars)

let events = store.events(matching: predicate)
  .filter { !$0.isAllDay && $0.status != .canceled && $0.endDate > now }
  .filter { event in
    // Skip meetings I declined.
    event.attendees?.first(where: { $0.isCurrentUser })?.participantStatus != .declined
  }
  .sorted { $0.startDate < $1.startDate }

// A meeting starting within 15 minutes beats one already in progress
// (e.g. a long "Focus time" block shouldn't hide the call that's about to start).
let soon = events.first { $0.startDate > now && $0.startDate.timeIntervalSince(now) <= 15 * 60 }
guard let event = soon ?? events.first else { write(""); exit(0) }

let title = (event.title ?? "Busy").replacingOccurrences(of: "\t", with: " ")
  .replacingOccurrences(of: "\n", with: " ")
write("\(title)\t\(Int(event.startDate.timeIntervalSince1970))\t\(Int(event.endDate.timeIntervalSince1970))")
