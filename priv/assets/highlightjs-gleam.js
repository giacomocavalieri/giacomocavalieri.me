(() => {
  lang = (e) => {
    const KEYWORDS =
      "as assert case const fn if import let panic use opaque pub todo type";

    const KEYWORD = {
      className: "keyword",
      beginKeywords: KEYWORDS,
    };

    const STRING = {
      className: "string",
      variants: [{ begin: /"/, end: /"/ }],
      contains: [e.BACKSLASH_ESCAPE],
      relevance: 0,
    };

    const NAME = {
      className: "variable",
      begin: "\\b[a-z][a-z0-9_]*\\b",
      relevance: 0,
    };

    const DISCARD_NAME = {
      className: "comment",
      begin: "\\b_[a-z][a-z0-9_]*\\b",
      relevance: 0,
    };

    const NUMBER = {
      className: "number",
      variants: [
        {
          // binary
          begin: "\\b0[bB](?:_?[01]+)+",
        },
        {
          // octal
          begin: "\\b0[oO](?:_?[0-7]+)+",
        },
        {
          // hex
          begin: "\\b0[xX](?:_?[0-9a-fA-F]+)+",
        },
        {
          // dec, float
          begin: "\\b\\d(?:_?\\d+)*(?:\\.(?:\\d(?:_?\\d+)*)*)?",
        },
      ],
      relevance: 0,
    };

    const OPERATOR = {
      className: "operator",
      begin: "[+\\-*/%!=<>&|.]+",
      relevance: 0,
    };

    // Type names and constructors
    const UPNAME = {
      className: "title",
      begin: "\\b[A-Z][A-Za-z0-9]*\\b",
      relevance: 0,
    };

    const ATTRIBUTE = {
      className: "attribute",
      begin: "@",
      end: "\\(",
      excludeEnd: true,
    };

    const FUNCTION = {
      className: "function",
      beginKeywords: "fn",
      end: "\\(",
      excludeEnd: true,
      contains: [
        {
          className: "title",
          begin: "[a-z][a-z0-9_]*\\w*",
          relevance: 0,
        },
      ],
    };

    const BIT_ARRAY_KEYWORD = {
      className: "keyword",
      beginKeywords:
        "binary bits bytes int float bit_string bit_array bits utf8 utf16 " +
        "utf32 utf8_codepoint utf16_codepoint utf32_codepoint signed " +
        "unsigned big little native unit size",
    };

    const BIT_ARRAY = {
      begin: "<<",
      end: ">>",
      contains: [
        hljs.COMMENT("//", "$"),
        BIT_ARRAY_KEYWORD,
        KEYWORD,
        STRING,
        NAME,
        DISCARD_NAME,
        NUMBER,
      ],
      relevance: 10,
    };

    return {
      name: "Gleam",
      aliases: ["gleam"],
      contains: [
        hljs.COMMENT("//", "$"),
        STRING,
        BIT_ARRAY,
        FUNCTION,
        ATTRIBUTE,
        KEYWORD,
        UPNAME,
        OPERATOR,
        NAME,
        DISCARD_NAME,
        NUMBER,
      ],
    };
  };

  hljs.registerLanguage("gleam", lang);
})();
