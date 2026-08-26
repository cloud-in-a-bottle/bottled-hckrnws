# bottled-hckrnws

[hckrnws](https://github.com/rajatkulkarni95/hckrnws) is a clean,
mobile-friendly Hacker News reader. This repository packages the unmodified
upstream application for
[Cloud in a Bottle](https://github.com/cloud-in-a-bottle/cloud-in-a-bottle).

## What you get

- Top, new, best, Ask HN, and Show HN feeds
- Search across stories and comments
- Nested comment threads
- Dark and light themes
- Browser-local starred stories
- Public, account-free access

## How it works

The Docker build fetches the upstream commit pinned by `HCKRNWS_COMMIT`, builds
the React SPA, and copies the resulting static files into an unprivileged nginx
image. No hckrnws source is forked or vendored in this repository.

Each visitor's browser requests Hacker News data directly from the
[Algolia HN API](https://hn.algolia.com/api). The bottle does not proxy those
requests and has no persistent server-side state. Theme and starred-story
preferences remain in browser local storage.

## Deploying

```bash
bottle app deploy https://github.com/cloud-in-a-bottle/bottled-hckrnws --wait
```

The reader will be available at `https://hckrnws.<zone-domain>/`.

## Updating upstream

Change `HCKRNWS_COMMIT` in `Dockerfile`, update the matching commit and source
URL in `NOTICE`, then rebuild and exercise every feed, search, comments, and
bookmarks before publishing the update.

## Testing

Build and run the image on port 8080, then run:

```bash
./scripts/smoke-test.sh http://127.0.0.1:8080
```

The smoke test verifies health, SPA fallback routing, generated assets,
security headers, and missing-asset handling.

## License

hckrnws is MIT-licensed by Rajat Kulkarni. The wrapper files are also MIT.
See `LICENSE` and `NOTICE`; the upstream license is copied into every runtime
image.

This project is not affiliated with Y Combinator or Hacker News. Hacker News
content is sourced from and attributed to them.
