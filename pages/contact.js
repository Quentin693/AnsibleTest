import Head from 'next/head';
import styles from '../styles/Contact.module.css';

export default function Contact() {
  return (
    <div className={styles.container}>
      <Head>
        <title>Contact - Next.js App</title>
        <meta name="description" content="Contactez-nous" />
      </Head>

      <main className={styles.main}>
        <h1 className={styles.title}>Contactez-nous</h1>

        <p className={styles.description}>
          Vous avez une question ? N'hésitez pas à nous contacter !
        </p>

        <form className={styles.form}>
          <div className={styles.formGroup}>
            <label htmlFor="name">Nom</label>
            <input 
              type="text" 
              id="name" 
              name="name" 
              placeholder="Votre nom"
              required 
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="email">Email</label>
            <input 
              type="email" 
              id="email" 
              name="email" 
              placeholder="votre@email.com"
              required 
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="message">Message</label>
            <textarea 
              id="message" 
              name="message" 
              rows="5"
              placeholder="Votre message..."
              required
            ></textarea>
          </div>

          <button type="submit" className={styles.submitButton}>
            Envoyer le message
          </button>
        </form>

        <div className={styles.backLink}>
          <a href="/">← Retour à l'accueil</a>
        </div>
      </main>
    </div>
  );
}

