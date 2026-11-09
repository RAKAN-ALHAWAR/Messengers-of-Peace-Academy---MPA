const accountDeletionTranslations = <String, Map<String, String>>{
  'en': {
    'delete.explanation':
        'After you confirm with the email code, you will lose access to your account immediately and your identity will be hidden. Your learning records remain for reporting. The academy keeps an encrypted recovery copy. Contact support about recovery. There is no grace period or self-service recovery.',
    'delete.consent': 'I understand and want to continue.',
    'delete.send': 'Send confirmation code',
    'delete.resend': 'Send a new code',
    'delete.resendIn': 'Resend in @seconds s',
    'delete.sent':
        'Enter the code sent to your registered email. Check your spam folder if it does not arrive.',
    'delete.code': 'Six-digit email code',
    'delete.expires': 'Code expires in @seconds s',
    'delete.confirm': 'Confirm account deletion',
    'delete.sixDigits': 'Enter all six digits.',
    'delete.invalid': 'The code is invalid. Check it and try again.',
    'delete.expired':
        'The code expired or reached its attempt limit. Request a new code.',
    'delete.consentRequired':
        'Confirm that you understand what happens to your account before continuing.',
    'delete.rateLimited':
        'The send limit was reached. Wait before requesting another code.',
    'delete.busy': 'Another account operation is in progress. Try again later.',
    'delete.delivery':
        'The email could not be sent. Wait before trying again, or contact support.',
    'delete.supportRequired':
        'This account cannot be deleted in the app. Contact academy support.',
    'delete.unavailable':
        'Account deletion is currently unavailable. Contact academy support.',
    'delete.requestFailed':
        'Sending the code could not be confirmed. Wait before requesting another.',
    'delete.unknown':
        'We could not confirm whether your account was deleted. Return to sign in or contact academy support.',
    'delete.changed':
        'Your session changed. Open account deletion again to request a new code.',
    'delete.sessionExpired':
        'Your session expired. Sign in again or contact academy support.',
    'delete.returnToSignIn': 'Return to sign in',
    'delete.support': 'Contact academy support',
    'delete.success':
        'Account deletion confirmed. Contact academy support about recovery.',
    'delete.cleanupIncomplete':
        'Account deletion confirmed. Some local data could not be cleared. Contact academy support.',
  },
  'ar': {
    'delete.explanation':
        'بعد تأكيد رمز البريد ستفقد إمكانية الدخول إلى حسابك فوراً وتُخفى هويتك. يبقى سجلك التعليمي لأغراض التقارير. تحتفظ الأكاديمية بنسخة مشفّرة للاسترجاع. لا توجد مهلة أو استعادة ذاتية. للاستفسار عن الاسترجاع، تواصل مع الدعم.',
    'delete.consent': 'أفهم ما سيحدث وأريد المتابعة.',
    'delete.send': 'إرسال رمز التأكيد',
    'delete.resend': 'إرسال رمز جديد',
    'delete.resendIn': 'إعادة الإرسال بعد @seconds ثانية',
    'delete.sent':
        'أدخل الرمز المرسل إلى بريدك المسجّل. إذا لم يصلك، افحص مجلد البريد غير المرغوب فيه.',
    'delete.code': 'رمز البريد من 6 أرقام',
    'delete.expires': 'ينتهي الرمز بعد @seconds ثانية',
    'delete.confirm': 'تأكيد حذف الحساب',
    'delete.sixDigits': 'أدخل الأرقام الستة كاملة.',
    'delete.invalid': 'الرمز غير صحيح. تحقّق منه وحاول مجدداً.',
    'delete.expired':
        'انتهت صلاحية الرمز أو استُنفدت محاولاته. اطلب رمزاً جديداً.',
    'delete.consentRequired': 'أكّد أنك تفهم ما سيحدث لحسابك قبل المتابعة.',
    'delete.rateLimited': 'بلغت حد الإرسال. انتظر قبل طلب رمز جديد.',
    'delete.busy': 'هناك إجراء آخر جارٍ على الحساب. حاول لاحقاً.',
    'delete.delivery':
        'تعذّر إرسال البريد. انتظر قبل المحاولة أو تواصل مع الدعم.',
    'delete.supportRequired':
        'يتعذّر حذف هذا الحساب من التطبيق. تواصل مع دعم الأكاديمية.',
    'delete.unavailable':
        'حذف الحساب غير متاح حالياً. تواصل مع دعم الأكاديمية.',
    'delete.requestFailed':
        'تعذّر التأكد من إرسال الرمز. انتظر قبل طلب رمز جديد.',
    'delete.unknown':
        'تعذّر التأكد من نتيجة الحذف. ارجع إلى تسجيل الدخول أو تواصل مع دعم الأكاديمية.',
    'delete.changed': 'تغيّرت جلستك. افتح حذف الحساب مجدداً لطلب رمز جديد.',
    'delete.sessionExpired':
        'انتهت جلستك. سجّل الدخول مجدداً أو تواصل مع دعم الأكاديمية.',
    'delete.returnToSignIn': 'العودة إلى تسجيل الدخول',
    'delete.support': 'التواصل مع دعم الأكاديمية',
    'delete.success':
        'تم تأكيد حذف الحساب. للاستفسار عن الاسترجاع، تواصل مع دعم الأكاديمية.',
    'delete.cleanupIncomplete':
        'تم تأكيد حذف الحساب. تعذّر مسح بعض البيانات على هذا الجهاز. تواصل مع دعم الأكاديمية.',
  },
  'es': {
    'delete.explanation':
        'Al confirmar el código del correo, perderás el acceso de inmediato y se ocultará tu identidad. El registro de aprendizaje se conserva para informes. La academia guarda una copia cifrada para recuperación. No hay plazo de gracia ni recuperación por tu cuenta. Consulta con soporte.',
    'delete.consent': 'Lo entiendo y quiero continuar.',
    'delete.send': 'Enviar código de confirmación',
    'delete.resend': 'Enviar un código nuevo',
    'delete.resendIn': 'Reenviar en @seconds s',
    'delete.sent':
        'Introduce el código enviado a tu correo registrado. Si no llega, revisa el correo no deseado.',
    'delete.code': 'Código de correo de 6 dígitos',
    'delete.expires': 'El código caduca en @seconds s',
    'delete.confirm': 'Confirmar la eliminación',
    'delete.sixDigits': 'Introduce los seis dígitos.',
    'delete.invalid':
        'El código no es válido. Compruébalo e inténtalo de nuevo.',
    'delete.expired':
        'El código caducó o alcanzó el límite de intentos. Solicita otro.',
    'delete.consentRequired':
        'Confirma que entiendes qué sucederá con tu cuenta.',
    'delete.rateLimited':
        'Se alcanzó el límite de envíos. Espera antes de solicitar otro código.',
    'delete.busy': 'Hay otra operación en curso. Inténtalo más tarde.',
    'delete.delivery':
        'No se pudo enviar el correo. Espera o contacta con soporte.',
    'delete.supportRequired':
        'Esta cuenta no se puede eliminar desde la aplicación. Contacta con soporte.',
    'delete.unavailable':
        'La eliminación no está disponible. Contacta con soporte.',
    'delete.requestFailed':
        'No se pudo confirmar el envío. Espera antes de pedir otro código.',
    'delete.unknown':
        'No se pudo confirmar si se eliminó la cuenta. Vuelve al inicio de sesión o contacta con soporte.',
    'delete.changed':
        'La sesión cambió. Vuelve a abrir la eliminación para pedir otro código.',
    'delete.sessionExpired':
        'La sesión caducó. Inicia sesión de nuevo o contacta con soporte.',
    'delete.returnToSignIn': 'Volver al inicio de sesión',
    'delete.support': 'Contactar con soporte',
    'delete.success':
        'Se confirmó la eliminación. Consulta con soporte sobre la recuperación.',
    'delete.cleanupIncomplete':
        'Se confirmó la eliminación. No se pudieron borrar algunos datos locales. Contacta con soporte.',
  },
  'fil': {
    'delete.explanation':
        'Pagkumpirma sa code sa email, agad na mawawala ang access sa account at itatago ang pagkakakilanlan mo. Mananatili ang tala ng pag-aaral para sa mga ulat. May naka-encrypt na kopya ang akademya para sa pagbawi. Walang palugit o sariling paraan ng pagbawi. Makipag-ugnayan sa suporta.',
    'delete.consent': 'Nauunawaan ko at gusto kong magpatuloy.',
    'delete.send': 'Ipadala ang code ng kumpirmasyon',
    'delete.resend': 'Magpadala ng bagong code',
    'delete.resendIn': 'Magpadala muli sa loob ng @seconds s',
    'delete.sent':
        'Ilagay ang code na ipinadala sa rehistradong email. Tingnan ang spam folder kung wala ito.',
    'delete.code': 'Code sa email na may 6 na digit',
    'delete.expires': 'Mag-e-expire ang code sa loob ng @seconds s',
    'delete.confirm': 'Kumpirmahin ang pagbura ng account',
    'delete.sixDigits': 'Ilagay ang lahat ng anim na digit.',
    'delete.invalid': 'Hindi wasto ang code. Suriin ito at subukan muli.',
    'delete.expired':
        'Nag-expire ang code o naubos ang mga pagsubok. Humiling ng bagong code.',
    'delete.consentRequired':
        'Kumpirmahing nauunawaan mo ang mangyayari sa account.',
    'delete.rateLimited':
        'Naabot ang limitasyon sa pagpapadala. Maghintay bago humiling muli.',
    'delete.busy': 'May iba pang proseso sa account. Subukan muli mamaya.',
    'delete.delivery':
        'Hindi naipadala ang email. Maghintay o makipag-ugnayan sa suporta.',
    'delete.supportRequired':
        'Hindi mabubura ang account na ito sa app. Makipag-ugnayan sa suporta.',
    'delete.unavailable':
        'Hindi available ang pagbura ngayon. Makipag-ugnayan sa suporta.',
    'delete.requestFailed':
        'Hindi nakumpirma ang pagpapadala. Maghintay bago humiling ng panibagong code.',
    'delete.unknown':
        'Hindi makumpirma kung nabura ang account. Bumalik sa pag-sign in o makipag-ugnayan sa suporta.',
    'delete.changed':
        'Nagbago ang session. Buksan muli ang pagbura ng account para humiling ng bagong code.',
    'delete.sessionExpired':
        'Nag-expire ang session. Mag-sign in muli o makipag-ugnayan sa suporta.',
    'delete.returnToSignIn': 'Bumalik sa pag-sign in',
    'delete.support': 'Makipag-ugnayan sa suporta',
    'delete.success':
        'Nakumpirma ang pagbura. Makipag-ugnayan sa suporta tungkol sa pagbawi.',
    'delete.cleanupIncomplete':
        'Nakumpirma ang pagbura. May lokal na datos na hindi nabura. Makipag-ugnayan sa suporta.',
  },
};
