import SwiftUI

struct ConjugationView: View {
    
    let conjugation: Conjugation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                participes
                tense(conjugation.present, title: "Présent")
                tense(conjugation.imperfect, title: "Imparfait")
                tense(conjugation.pastHistoric, title: "Passé simple")
                tense(conjugation.future, title: "Futur")
                tense(conjugation.subjonctivePresent, title: "Subjonctif présent")
                tense(conjugation.subjonctiveImperfect, title: "Subjonctif imparfait")
                imperative
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle(conjugation.infinitive)
    }
    
    private func conjugation(
        _ firstPerson: String,
        _ firstTerm: String,
        _ secondPerson: String = "",
        _ secondTerm: String = ""
    ) -> some View {
        VStack(alignment: .leading) {
            if !firstPerson.isEmpty && !firstTerm.isEmpty {
                Text(firstPerson)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(firstTerm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            if !secondPerson.isEmpty && !secondTerm.isEmpty {
                Text(secondPerson)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                Text(secondTerm)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }
    
    private var participes: some View {
        HStack {
            Spacer()
            conjugation("Participe présent", conjugation.presentParticiple)
            Spacer()
            conjugation("Particip passé", conjugation.compoundVerb + " + " + conjugation.pastParticiple)
            Spacer()
        }
        .withBackground()
    }

    private func tense(_ tense: Tense, title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .bold()
            HStack {
                conjugation("je", tense.conjugations[0], "nous", tense.conjugations[3])
                Spacer()
                conjugation("tu", tense.conjugations[1], "vous", tense.conjugations[4])
                Spacer()
                conjugation("il / elle", tense.conjugations[2], "ils / elles", tense.conjugations[5])
            }
        }
        .withBackground()
    }
    
    private var imperative: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Impératif")
                .font(.subheadline)
                .bold()
            HStack {
                conjugation("je", "-", "nous", conjugation.imperative.conjugations[1])
                Spacer()
                conjugation("tu", conjugation.imperative.conjugations[0], "vous", conjugation.imperative.conjugations[2])
                Spacer()
                conjugation("il / elle", "-", "ils / elles", "-")
            }
        }
        .withBackground()
    }
    
    struct BackgroundModifier: ViewModifier {

        func body(content: Content) -> some View {
            content
                .padding(16)
                .background {
                    RoundedRectangle(cornerRadius: 4).foregroundColor(.primary)
                        .overlay { RoundedRectangle(cornerRadius: 3).foregroundColor(.background).padding(1) }
                        .shadow(radius: 1, y: 2)
                }
        }
    }
    
}

extension Color {
    
    static var background: Self {
        .init(uiColor: .systemBackground)
    }
}

private extension View {
    
    func withBackground() -> some View {
        modifier(ConjugationView.BackgroundModifier())
    }
    
}

struct ConjugationViewPreviews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            ConjugationView(conjugation: .init(strings: .init(repeating: "hello", count: 50))!)
        }
    }
    
}
