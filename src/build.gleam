import blog/page
import blog/post.{type Post}
import blog/rss
import filepath
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/string
import lustre/element
import simplifile
import temporary

const out_dir = "site"

const assets_dir = "assets"

const posts_dir = "posts"

const tags_dir = "tags"

pub fn main() {
  let all_posts = read_posts()
  let posts = list.filter(all_posts, keeping: post.is_shown)
  let chronological_posts = list.sort(posts, by: order.reverse(post.compare))

  // We do everything in a temporary directory and then copy it to the final
  // destination. This way we don't have to take care of cleaning everything up
  // if something fails halfways through, at the end we will just copy the
  // temporary directory to the `site` folder.
  //
  // This is a quick script that generates my personal site, so error handling
  // is not that crucial! We're totally fine with panicking if something goes
  // wrong along the way
  let assert Ok(Nil) = {
    use directory <- temporary.create(temporary.directory())

    let assert Ok(_) =
      page.homepage(chronological_posts)
      |> element.to_document_string
      |> simplifile.write(to: filepath.join(directory, "index.html"))
      as "failed to create index.html"

    let assert Ok(_) =
      page.not_found()
      |> element.to_document_string
      |> simplifile.write(to: filepath.join(directory, "404.html"))
      as "failed to create 404.html"

    let assert Ok(_) =
      page.from_post(read_post("uses.md"))
      |> element.to_document_string
      |> simplifile.write(to: filepath.join(directory, "uses.html"))
      as "failed to create uses.html"

    let assert Ok(_) =
      rss.feed_from_posts(chronological_posts)
      |> element.to_string
      |> string.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", _)
      |> simplifile.write(to: filepath.join(directory, "feed.xml"))
      as "failed to create feed.xml"

    let posts_dir = filepath.join(directory, posts_dir)
    let assert Ok(_) = simplifile.create_directory(posts_dir)
    list.each(posts, fn(post) {
      let post_file = post.meta.id <> ".html"
      let assert Ok(_) =
        page.from_post(post)
        |> element.to_document_string
        |> simplifile.write(to: filepath.join(posts_dir, post_file))
        as { "failed to create post " <> post_file }
    })

    let tags_dir = filepath.join(directory, tags_dir)
    let assert Ok(_) = simplifile.create_directory(tags_dir)
    list.each(dict.to_list(group_by_tags(posts)), fn(entry) {
      let #(tag, posts) = entry
      let tag_file = tag <> ".html"
      let assert Ok(_) =
        page.from_tag(tag, posts)
        |> element.to_document_string
        |> simplifile.write(to: filepath.join(tags_dir, tag_file))
        as { "failed to create tag page " <> tag_file }
    })

    let assert Ok(_) = simplifile.copy_directory(assets_dir, directory)
      as "failed to copy assets"
    let _ = simplifile.delete(out_dir)
    let assert Ok(_) = simplifile.create_directory(out_dir)
      as "failed to create final output directory"
    let assert Ok(_) = simplifile.copy_directory(directory, out_dir)
      as "failed to copy temporary directory into output directory"

    Nil
  }

  io.println("Done!")
}

// POST READING ----------------------------------------------------------------

fn read_post(named name: String) -> Post {
  let assert Ok(post) = post.read(from: filepath.join(posts_dir, name))
  post
}

fn read_posts() -> List(Post) {
  let assert Ok(paths) = simplifile.read_directory(posts_dir)
  use file <- list.map(paths)
  let assert Ok(post) = post.read(from: filepath.join(posts_dir, file))
  post
}

fn group_by_tags(posts: List(Post)) -> Dict(String, List(Post)) {
  use tagged_posts, post <- list.fold(over: posts, from: dict.new())
  use tagged_posts, tag <- list.fold(over: post.meta.tags, from: tagged_posts)
  use posts <- dict.upsert(in: tagged_posts, update: tag)
  case posts {
    Some(posts) -> [post, ..posts]
    None -> [post]
  }
}
