import puppeteer from 'puppeteer'
import pages from './pages.mjs'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const keepaliveDir = path.resolve(__dirname);

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    executablePath: '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
  })

  for (const pageInfo of pages) {
    const page = await browser.newPage()
    await page.goto(pageInfo.url)

    const beforeScreenshot = path.join(keepaliveDir, `before_click_${pageInfo.url.replace(/[^a-zA-Z0-9]/g, '_')}.png`)
    await page.screenshot({ path: beforeScreenshot })

    const buttonClicked = await page.evaluate((text) => {
      const button = Array.from(document.querySelectorAll('button')).find(el => el.textContent.trim() === text)
      if (button) {
        button.click()
        return true
      }
      return false
    }, pageInfo.text)

    console.log(`Button clicked on ${pageInfo.url}:`, buttonClicked)

    const afterScreenshot = path.join(keepaliveDir, `after_click_${pageInfo.url.replace(/[^a-zA-Z0-9]/g, '_')}.png`)
    console.log(`Taking screenshot after clicking the button: ${afterScreenshot}`)
    await page.screenshot({ path: afterScreenshot })

    await page.close()
  }

  await browser.close()
})()
