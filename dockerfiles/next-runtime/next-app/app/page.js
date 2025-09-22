export default function Home() {
  return (
    <main className="container">
      <h1>Welcome to Next.js on WebVM</h1>
      <p>
        This image boots directly into <code>npm run dev</code> so you can edit and preview
        your Next.js application from the browser.
      </p>
      <section className="instructions">
        <h2>Next steps</h2>
        <ol>
          <li>Open the <code>/home/user/next-app</code> folder in your editor.</li>
          <li>Run <code>npm install</code> after adding dependencies.</li>
          <li>Use <code>npm run build</code> followed by <code>npm start</code> for production mode.</li>
        </ol>
      </section>
    </main>
  );
}
