import Foundation
import Testing
@testable import Services

@MainActor
@Suite("ParentalConsentService")
struct ParentalConsentServiceTests {

    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    @Test("Fresh service has no consent + reports neither valid nor expired")
    func freshHasNoConsent() throws {
        let service = ParentalConsentService(defaults: makeSuite())
        #expect(service.grantedAt == nil)
        #expect(!service.hasValidConsent)
        #expect(!service.isExpired)
        #expect(service.daysUntilReconsent == nil)
    }

    @Test("grant() persists timestamp + flips hasValidConsent true")
    func grantPersists() throws {
        let suite = makeSuite()
        let service = ParentalConsentService(defaults: suite)
        service.grant()
        #expect(service.hasValidConsent)
        #expect(service.grantedAt != nil)
        // Persistence survives re-instantiation against the same defaults.
        let restored = ParentalConsentService(defaults: suite)
        #expect(restored.hasValidConsent)
        #expect(restored.grantedAt != nil)
    }

    @Test("revoke() removes the record")
    func revokeClears() throws {
        let service = ParentalConsentService(defaults: makeSuite())
        service.grant()
        #expect(service.hasValidConsent)
        service.revoke()
        #expect(!service.hasValidConsent)
        #expect(service.grantedAt == nil)
    }

    @Test("Consent expires after 12 months per FTC 2026")
    func expiresAfterTwelveMonths() throws {
        let suite = makeSuite()
        let base = Date(timeIntervalSince1970: 0)
        let grantClock = { base }
        let expiredClock = { base.addingTimeInterval(ParentalConsentService.consentValidity + 1) }
        let granter = ParentalConsentService(defaults: suite, clock: grantClock)
        granter.grant()
        // Same store, advanced clock — consent must report expired.
        let later = ParentalConsentService(defaults: suite, clock: expiredClock)
        #expect(later.isExpired)
        #expect(!later.hasValidConsent)
        #expect(later.daysUntilReconsent == 0)
    }

    @Test("daysUntilReconsent counts down sensibly")
    func daysCountDown() throws {
        let suite = makeSuite()
        let base = Date(timeIntervalSince1970: 0)
        let granter = ParentalConsentService(defaults: suite, clock: { base })
        granter.grant()
        // 30 days later — daysUntilReconsent should be ~335.
        let later = ParentalConsentService(
            defaults: suite,
            clock: { base.addingTimeInterval(86_400 * 30) }
        )
        let days = try #require(later.daysUntilReconsent)
        #expect(days >= 333 && days <= 337)
    }
}

@Suite("CrisisResourcesProvider")
struct CrisisResourcesProviderTests {
    @Test("Ships the canonical 988 / Childhelp / Crisis Text Line trio")
    func canonicalTrio() throws {
        let ids = CrisisResourcesProvider.resources.map(\.id)
        #expect(ids.contains("988"))
        #expect(ids.contains("childhelp"))
        #expect(ids.contains("crisis-text-line"))
    }

    @Test("988 entry has phone + URL populated")
    func nineEightEightFields() throws {
        let r = try #require(
            CrisisResourcesProvider.resources.first { $0.id == "988" }
        )
        #expect(r.phoneNumber == "988")
        #expect(r.url != nil)
    }

    @Test("Crisis Text Line entry includes the HOME-to-741741 instructions")
    func textLineInstructions() throws {
        let r = try #require(
            CrisisResourcesProvider.resources.first { $0.id == "crisis-text-line" }
        )
        let text = try #require(r.textInstructions)
        #expect(text.contains("741741"))
        #expect(text.contains("HOME"))
    }
}
