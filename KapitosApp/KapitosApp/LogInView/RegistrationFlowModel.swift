import Foundation
import Combine

final class RegistrationFlowModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""

    struct PreferencesData {
        var processes: Set<String> = []
        var roasts: Set<String> = []
        var drinks: Set<String> = []
        var times: Set<String> = []
        var acidity: Set<String> = []
        var notes: Set<String> = []
        var weekly: Set<String> = []
    }

    @Published var preferences = PreferencesData()

    var hasAnyPreferenceSelections: Bool {
        !preferences.processes.isEmpty || !preferences.roasts.isEmpty || !preferences.drinks.isEmpty || !preferences.times.isEmpty || !preferences.acidity.isEmpty || !preferences.notes.isEmpty || !preferences.weekly.isEmpty
    }
}
