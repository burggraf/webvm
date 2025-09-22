import './globals.css';

export const metadata = {
  title: 'WebVM Next.js runtime',
  description: 'Starter template for building Next.js applications inside WebVM.',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
