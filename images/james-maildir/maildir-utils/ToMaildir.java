// Custom Java class to deliver locally-bound emails to the appropriate maildir
// version 1.0.0 - Malcolm Schongalla 20250428

package org.apache.james.transport.mailets;

import java.io.IOException;
import java.io.OutputStream;

import jakarta.mail.MessagingException;

import org.apache.james.core.MailAddress;
import org.apache.mailet.base.GenericMailet;
import org.apache.mailet.Mail;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Delivers incoming Mail to a local Maildir using a custom shell script.
 * Sets the user ID and $HOME for the process environment that invokes the delivery script.
 */
public class ToMaildir extends GenericMailet {
    private static final Logger LOGGER = LoggerFactory.getLogger(ToMaildir.class);

    private String scriptPath;
    private boolean passThrough = false;

    public ToMaildir() {
        // Intentionally left blank
    }

    @Override
    public void init() throws MessagingException {
        this.passThrough = getPassThroughParameter();
        this.scriptPath = getInitParameter("scriptPath", "/app/localdelivery.sh");
        LOGGER.info("ToMaildir initialized with scriptPath: {}", scriptPath);
    }

    private boolean getPassThroughParameter() {
        try {
            return getInitParameter("passThrough", false);
        } catch (Exception e) {
            return false;
        }
    }

    @Override
    public void service(Mail mail) throws MessagingException {
        try {
            if (mail.getMessage() != null) {
                LOGGER.info("Processing mail: {}", mail.getName());
                deliverToMaildir(mail);
            } else {
                LOGGER.warn("Mail content is null, skipping delivery: {}", mail.getName());
            }
            if (!passThrough) {
                mail.setState(Mail.GHOST);
            }
        } catch (IOException e) {
            throw new MessagingException("Failed to deliver mail to Maildir", e);
        }
    }

    private void deliverToMaildir(Mail mail) throws IOException, MessagingException {
        for (MailAddress recipient : mail.getRecipients()) {
            String recipientEmail = recipient.asString();
            String username = recipientEmail.split("@")[0];
            String homeDirectory = "/home/" + username;

            ProcessBuilder processBuilder = new ProcessBuilder(scriptPath);
            processBuilder.environment().put("USER", username);
            processBuilder.environment().put("HOME", homeDirectory);

            Process process = processBuilder.start();

            try (OutputStream stdin = process.getOutputStream()) {
                mail.getMessage().writeTo(stdin);
            }

            int exitCode;
            try {
                exitCode = process.waitFor();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new MessagingException("Process was interrupted", e);
            }

            if (exitCode == 0) {
                LOGGER.info("Successfully delivered mail {} to Maildir of user {}", mail.getName(), username);
            } else {
                LOGGER.error("Failed to deliver mail {} to Maildir of user {}, exit code: {}", mail.getName(), username, exitCode);
            }
        }
    }

}

