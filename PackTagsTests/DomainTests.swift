import Testing
@testable import PackTags

// MARK: - HashtagParser

@Suite struct HashtagParserTests {

    @Test func parse_extractsHashtagsAndIgnoresPlainText() {
        #expect(HashtagParser.parse("#sea #sun a day at #beach") == ["#sea", "#sun", "#beach"])
    }

    @Test func parse_excludesRightToLeftScriptHashtags() {
        #expect(HashtagParser.parse("#hello #שלום #مرحبا #world") == ["#hello", "#world"])
    }

    @Test func parse_returnsEmptyWhenNoHashtags() {
        #expect(HashtagParser.parse("just some words").isEmpty)
    }
}

// MARK: - TagPackFormatter

@Suite struct TagPackFormatterTests {

    @Test func packs_chunksTagsIntoGroupsOfRequestedSize() {
        let packs = TagPackFormatter.packs(from: "#a #b #c #d", tagsPerPack: 2)
        #expect(packs == ["#a #b", "#c #d"])
    }

    @Test func packs_lastPackKeepsRemainder() {
        let packs = TagPackFormatter.packs(from: "#a #b #c", tagsPerPack: 2)
        #expect(packs == ["#a #b", "#c"])
    }

    @Test func format_joinsPacksWithBlankLine() {
        let formatted = TagPackFormatter.format("#a #b #c", tagsPerPack: 2)
        #expect(formatted == "#a #b\n\n#c")
    }
}

// MARK: - TagDeduplicator

@Suite struct TagDeduplicatorTests {

    private func makeRepository() -> CoreDataThemeRepository {
        CoreDataThemeRepository(context: PersistenceController(inMemory: true).viewContext)
    }

    @Test func sanitize_removesDuplicateTagsWithinInput() {
        let sut = TagDeduplicator(repository: makeRepository())

        let result = sut.sanitize(rawText: "#a #a #b some text #b", currentThemeContent: nil, shuffle: false)

        #expect(result == "#a #b")
    }

    @Test func sanitize_removesTagsAlreadyStoredInOtherThemes() {
        let repository = makeRepository()
        let otherTheme = repository.create()
        otherTheme.content = "#stored"
        repository.save()
        let sut = TagDeduplicator(repository: repository)

        let result = sut.sanitize(rawText: "#stored #fresh", currentThemeContent: nil, shuffle: false)

        #expect(result == "#fresh")
    }

    @Test func sanitize_keepsTagsBelongingToTheCurrentTheme() {
        let repository = makeRepository()
        let currentTheme = repository.create()
        currentTheme.content = "#mine #also"
        let otherTheme = repository.create()
        otherTheme.content = "#stored"
        repository.save()
        let sut = TagDeduplicator(repository: repository)

        let result = sut.sanitize(rawText: "#mine #also #stored #fresh", currentThemeContent: currentTheme.content, shuffle: false)

        #expect(result == "#mine #also #fresh")
    }

    @Test func sanitize_shuffle_preservesTheTagSet() {
        let sut = TagDeduplicator(repository: makeRepository())

        let result = sut.sanitize(rawText: "#a #b #c #d", currentThemeContent: nil, shuffle: true)

        #expect(Set(result.components(separatedBy: " ")) == Set(["#a", "#b", "#c", "#d"]))
    }
}
