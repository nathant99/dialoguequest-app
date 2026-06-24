import Foundation
import ForgeContent

/// Two-tier content loader for kit JSONs.
///
/// Wraps ForgeKit 0.99's `ForgeContentLoader` (disk cache first, bundle
/// fallback second) so the AppFeature layer's `QuestionKitLoader` can
/// delegate kit lookup through a portfolio-canonical seam. Today the
/// disk cache is always empty (no hub-shipped kit manifest URL), so
/// every load transparently falls through to the configured bundle —
/// behavior identical to the pre-seam `Bundle.module.url(...)` lookup.
///
/// The seam exists so a future PR can hand `ForgeContentLoader` a real
/// `manifestURL` (or a pre-populated `cacheDirectory`) without touching
/// the AppFeature consumer or changing the wire-level JSON shape. See
/// `forgekit/Sources/Client/ForgeContent/README.md` for the manifest +
/// `ForgeContentSync` pipeline that lights up the OTA path.
///
/// Per `.claude/rules/spm-architecture.md` § "Access Control" + the
/// SPM file layout convention, this lives in `Services/Persistence/`
/// because it sits alongside `DialoguePersistenceService` /
/// `AnthologyCollectionService` / `CharacterForgeImportService` in the
/// "where do we get our data from" responsibility column. Pure value
/// type; `Sendable` via `nonisolated public struct`.
public nonisolated struct QuestionKitContentService: Sendable {

    /// Errors surfaced to consumers. Strictly narrower than
    /// `ForgeContentError` so AppFeature callers don't have to import
    /// ForgeContent just to switch on outcomes.
    public enum LoadError: Error, Sendable, Equatable {
        /// The file did not exist in the disk cache or the configured
        /// bundle. Carries the resource ID (no extension) for caller-
        /// side error wrapping.
        case notFound(String)
        /// The file existed but failed to decode into the requested
        /// type. Carries a short reader-neutral detail string (extracted
        /// from the underlying decoder when available).
        case decodeFailed(String)
    }

    /// Optional override for the disk cache directory. `nil` defaults to
    /// `Application Support/ForgeContent` per the ForgeContentLoader
    /// convention. Tests pass a temporary directory here.
    public let cacheDirectory: URL?

    /// Bundle used as the second-tier fallback. AppFeature consumers
    /// pass `Bundle.module` (the AppFeature target's resource bundle);
    /// tests pass a custom test-bundle URL.
    public let bundle: Bundle

    public init(bundle: Bundle, cacheDirectory: URL? = nil) {
        self.bundle = bundle
        self.cacheDirectory = cacheDirectory
    }

    /// Loads + decodes a JSON file. Two-tier lookup: disk cache first,
    /// then the configured bundle. Maps `ForgeContentError` to
    /// `LoadError` so consumers see a stable error vocabulary.
    public func load<T: Decodable & Sendable>(
        _ type: T.Type,
        filename: String
    ) throws -> T {
        let loader = ForgeContentLoader(cacheDirectory: cacheDirectory, bundle: bundle)
        do {
            return try loader.load(type, filename: filename)
        } catch let error as ForgeContentError {
            switch error {
            case .fileNotFound(let name):
                let resourceID = (name as NSString).deletingPathExtension
                throw LoadError.notFound(resourceID.isEmpty ? name : resourceID)
            case .manifestFetchFailed(let detail), .decodingFailed(let detail):
                throw LoadError.decodeFailed(detail)
            }
        } catch let decodingError as DecodingError {
            throw LoadError.decodeFailed(Self.shortDescription(of: decodingError))
        } catch {
            throw LoadError.decodeFailed(filename)
        }
    }

    private static func shortDescription(of error: DecodingError) -> String {
        switch error {
        case .typeMismatch(_, let context):
            return "typeMismatch: \(context.debugDescription)"
        case .valueNotFound(_, let context):
            return "valueNotFound: \(context.debugDescription)"
        case .keyNotFound(let key, _):
            return "keyNotFound: \(key.stringValue)"
        case .dataCorrupted(let context):
            return "dataCorrupted: \(context.debugDescription)"
        @unknown default:
            return "decodingError"
        }
    }
}
