import { Empty, NonEmpty } from "./gleam.mjs";
import { fromMarkdown } from "mdast-util-from-markdown";
import * as Markdown from "./markdown/ffi_builders.mjs";

const empty = new Empty();
const fold_into_list = (arr, f) => arr.reduceRight((acc, val) => new NonEmpty(f(val), acc), empty);

export function parse(markdown) {
  const ast = fromMarkdown(markdown);
  const content = fold_into_list(
    ast.children,
    function to_lustre_element(node) {
      switch (node.type) {
        case "code": return Markdown.code(node.value, node.lang);
        case "emphasis": return Markdown.emphasis(fold_into_list(node.children, to_lustre_element));
        case "heading": return Markdown.heading(node.depth, fold_into_list(node.children, to_lustre_element));
        case "inlineCode": return Markdown.inline_code(node.value);
        case "link": return Markdown.link(node.url, fold_into_list(node.children, to_lustre_element));
        case "list": return Markdown.list(!!node.ordered, fold_into_list(node.children, to_lustre_element));
        case "listItem": return Markdown.list_item(fold_into_list(node.children, to_lustre_element));
        case "paragraph": return Markdown.paragraph(fold_into_list(node.children, to_lustre_element));
        case "strong": return Markdown.strong(fold_into_list(node.children, to_lustre_element));
        case "text": return Markdown.text(node.value);
        case "blockquote": return Markdown.blockquote(fold_into_list(node.children, to_lustre_element));
        default: return Markdown.error();
      }
    }
  );
  return content;
}