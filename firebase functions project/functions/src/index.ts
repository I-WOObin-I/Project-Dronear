import * as functions from 'firebase-functions';
import * as sgMail from '@sendgrid/mail';

// Replace with your actual SendGrid API key
sgMail.setApiKey('YOUR_SENDGRID_API_KEY');

// HTTP-triggered function to send email
export const sendEmail = functions.https.onRequest(async (req, res) => {
  const { recipient, subject, body } = req.body;

  if (!recipient || !subject || !body) {
    res.status(400).send('Missing fields');
    return;
  }

  const msg = {
    to: recipient,
    from: 'your_verified_sendgrid_email@example.com', // Must be a verified sender in SendGrid
    subject: subject,
    text: body,
  };

  try {
    await sgMail.send(msg);
    res.status(200).send({ success: true });
  } catch (error: any) {
    res.status(500).send({ error: error.toString() });
  }
});