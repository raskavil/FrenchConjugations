import SwiftUI

struct VerbsList: View {
    
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.displayedConjugations) { verb in
                NavigationLink(destination: { ConjugationView(conjugation: verb) }, label: { Text(verb.infinitive) })
            }
            .searchable(text: $viewModel.searchTerm)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .navigationTitle("Conjugations")
        }
    }
}
