# Xibe Chat Documentation Website

This is the static documentation website for Xibe Chat.

## Viewing the Website

### Local Development

Simply open `index.html` in your web browser:

```bash
# Option 1: Direct file open
open index.html  # macOS
xdg-open index.html  # Linux
start index.html  # Windows

# Option 2: Using Python HTTP server
python3 -m http.server 8000
# Then visit http://localhost:8000

# Option 3: Using Node.js http-server
npx http-server
# Then visit http://localhost:8080
```

### Deploying

#### GitHub Pages

1. Push to repository
2. Go to Settings → Pages
3. Select source branch
4. Site will be available at `https://yourusername.github.io/xibe-chat`

#### Netlify

1. Drag and drop the `site` folder to Netlify
2. Or connect GitHub repository
3. Site will be deployed automatically

#### Vercel

1. Install Vercel CLI: `npm i -g vercel`
2. Run `vercel` in this directory
3. Follow the prompts

## Structure

- `index.html` - Main documentation page
- `../docs/` - Markdown documentation files
- Links to detailed guides in the docs folder

## Features

- Responsive design (mobile-friendly)
- Dark theme matching app design
- Smooth animations and transitions
- Easy navigation
- Feature showcase
- Installation guides
- User documentation
- Developer resources

## Customization

Edit `index.html` to customize:

- Colors (see CSS variables in `<style>`)
- Content sections
- Feature cards
- Links and navigation

## Maintenance

When updating documentation:

1. Update markdown files in `../docs/`
2. Update `index.html` if adding new sections
3. Test responsive design
4. Deploy changes

## Technologies

- Pure HTML, CSS, JavaScript
- No build step required
- No dependencies
- Works offline
- Fast and lightweight

---

For more information, see the main [README](../docs/README.md).
