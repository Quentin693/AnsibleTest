import Head from 'next/head';
import styles from '../styles/Home.module.css';

export default function Home() {
  return (
    <div className={styles.container}>
      <Head>
        <title>Next.js - Déploiement Ansible</title>
        <meta name="description" content="Application Next.js déployée avec Ansible et GitHub Actions" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <h1 className={styles.title}>
          Bienvenue sur <span className={styles.highlight}>Next.js</span>
        </h1>

        <p className={styles.description}>
          Application déployée automatiquement avec Ansible et GitHub Actions 🚀
        </p>

        <div className={styles.grid}>
          <div className={styles.card}>
            <h2>📦 Étape 1</h2>
            <p>Configuration des ports AWS EC2</p>
          </div>

          <div className={styles.card}>
            <h2>🔧 Étape 2</h2>
            <p>Installation de Git, Nginx et Node.js</p>
          </div>

          <div className={styles.card}>
            <h2>⚙️ Étape 3</h2>
            <p>Déploiement manuel avec Ansible</p>
          </div>

          <div className={styles.card}>
            <h2>🤖 Étape 4</h2>
            <p>Automatisation CI/CD avec GitHub Actions</p>
          </div>
        </div>

        <div className={styles.status}>
          <p>✅ Déploiement réussi !</p>
          <p>Version: 1.0.0</p>
        </div>
      </main>

      <footer className={styles.footer}>
        <p>Projet EEMI - Déploiement CI/CD avec Ansible</p>
      </footer>
    </div>
  );
}

