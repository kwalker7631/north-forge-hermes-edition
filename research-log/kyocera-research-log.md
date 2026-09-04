# Kyocera Research Log

Append-only log of genuinely new, source-backed findings from scheduled research passes.
Classifications per field_claim_rule: Confirmed Fact / Strong Clue / Working Theory / Unverified Field Note.

## 2026-09-04 - TASKalfa 4-series failed-firmware recovery: selective DL_* file method + board swap notes
Source: https://www.copytechnet.com/forum/tech-support/kyocera/173485-2554-firmware-error (thread incl. retired Kyocera OEM tech "KYO_OEM")
Finding: On a TASKalfa 2554ci stuck in a boot-loop "Firmware Error PF-Under 0801" after a failed KFS firmware push, the recovery path shared by an ex-Kyocera OEM tech: strip the USB firmware package down to only the needed component files (keep all DL_CTRL* for main PWB, DL_ENGN* for engine, DL_SPNL*/DL_SPCF* for panel; remove the DL_ file for the failed component, e.g. DL_03V4 for the paper feeder), flash that, then reconnect the SSD/HDD and run the complete upgrade. Newer Iris2020-generation machines add a FW runtime security check (cert.pem + sign.bin per component), making single-component flashes require the matching .bin/.cert/.sign files. Also confirmed in-thread: 4-series main/engine boards CAN be swapped between machines despite Kyocera support claiming serial-number lock — swap one board at a time and run U004 to re-match serial numbers (this is what ultimately fixed the machine). Separate gotcha: if USB firmware load is ignored, check whether the USB port was disabled under device security settings.
Classification: Strong Clue (multi-tech corroborated forum procedure, incl. OEM-background source; not official Kyocera documentation)
Relevance: Direct field-service recovery procedure for bricked/looping firmware on 4-series TASKalfa — feeds kb-builder and assist-intake for "firmware error after KFS update" calls.

## 2026-09-04 - Kyocera published updated Security Best Practices guide (Aug 2026)
Source: https://www.kyoceradocumentsolutions.com/global/en/support-and-download/psirt.html (PDF filename dated 20260810)
Finding: Kyocera's global PSIRT page hosts a refreshed "Security Best Practices for Kyocera MFPs, Printers, and Production Printers" PDF dated 2026-08-10 (~5MB). The Security Bulletins list itself has had no new entries since the 2024-01-11 Device Manager vulnerability update — so the best-practices guide is the current security reference, not a new bulletin.
Classification: Confirmed Fact
Relevance: Reference document for hardening questions on security-sensitive accounts (sales-assist, kb-builder); also useful when customers' vulnerability scans flag Kyocera devices.

## 2026-09-04 - Kyocera firmware not publicly downloadable; vuln scans flagging gSOAP on TASKalfa fleet
Source: https://www.reddit.com/r/msp/comments/1oq445u/ (r/msp, Nov 2025; full thread not retrievable, logged from search-indexed summary)
Finding: MSPs report vulnerability scans returning gSOAP-related hits on TASKalfa all-in-one devices, and note that Kyocera device firmware is not available for public download (dealer/service-contract channel only) — leaving MSPs unable to self-remediate scan findings. Matches long-standing Kyocera distribution policy.
Classification: Unverified Field Note (thread body not fully retrieved; consistent with known Kyocera firmware distribution practice)
Relevance: Expect customer calls where a security scan flags a Kyocera MFP and the customer cannot obtain firmware themselves — the answer is dealer/TSC-initiated firmware update. Feeds assist-intake talk track.

## 2026-09-04 - KCPS client fails to open for subset of users despite services running
Source: https://www.reddit.com/r/sysadmin/comments/1owyjlh/ (r/sysadmin; full thread not retrievable, logged from search-indexed summary)
Finding: Field report that ~10% of staff at one org randomly cannot open the Kyocera Cloud Print and Scan (KCPS) desktop client even though all three KCPS Windows services are running; admin was unable to locate a useful event log. No confirmed cause or fix retrieved yet — worth watching for recurrence in our own KCPS install base.
Classification: Unverified Field Note
Relevance: KCPS client-side reliability symptom pattern for assist-intake; if a matching case comes through TSC, this suggests checking the client app layer (not the services) first.

## 2026-09-04 - HyPAS embedded-terminal ecosystem: API version and SNMPv3 install pitfalls (MyQ as bellwether)
Source: https://docs.myq-solution.com/en/kyo-emb/8.2/technical-changelog (MyQ Kyocera Embedded Terminal 8.2 release notes, patches through Aug 2026)
Finding: MyQ's Kyocera embedded (HyPAS) terminal changelog documents two install-relevant constraints that likely generalize to other HyPAS apps: (1) terminal installation fails outright on devices with HyPAS API version < 2.1.5 (fixed/handled in patch 22, Apr 2025); (2) installation via SNMPv3 was broken until patch 26 (Jun 2026) and requires the matching Print Server 10.2 patch 25+. Patch 27 (Aug 2026) is current. Also: some features (mixed-size Easy Copy, full-screen mode) explicitly require HyPAS 2.1.5+.
Classification: Confirmed Fact (vendor release notes)
Relevance: When third-party HyPAS terminal installs fail on older Kyocera hardware, check the device's HyPAS API version and the SNMP version used for deployment before blaming the app package. Feeds assist-intake and kb-builder for print-management-app install calls.
