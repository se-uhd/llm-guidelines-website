# LLM Guidelines Website

This website is built using [Jekyll](https://jekyllrb.com/), [Just the Docs](https://just-the-docs.github.io/just-the-docs/), and [GitHub Pages](https://pages.github.com/).
You can test changes to to website locally as follows:

1. Either install ruby directly or using [asdf](https://asdf-vm.com/) (see [.tool-versions](https://github.com/se-ubt/llm-guidelines-website/blob/main/.tool-versions)). If you're on Windows, we suggest using [WSL](https://learn.microsoft.com/en-us/windows/wsl/install).
2. Run `gem install bundler jekyll`.
3. Run `bundle install` in the root directory of this repo.
4. Run `bundle exec jekyll serve` to host the website locally.
5. Open `http://localhost:4000/` in your browser.

When you change the Markdown files, the local version of the website will automatically refresh (this does not apply to changes in the [configuration](https://github.com/se-ubt/llm-guidelines-website/blob/main/_config.yml), which you as a contributor usually don't need to modify).

Once you push your changes to the `main` branch or once a pull request is merged, the website is automatically redeployed via a GitHub Actions [workflow](https://github.com/se-ubt/llm-guidelines-website/blob/main/.github/workflows/pages.yml), which you can monitor [here](https://github.com/se-ubt/llm-guidelines-website).

We are free to use any editor you like, preferably one that supports [kramdown](https://kramdown.gettalong.org/), which is the [default Markdown renderer for Jekyll](https://jekyllrb.com/docs/configuration/markdown/#kramdown).
