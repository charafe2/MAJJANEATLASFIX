String format212(String phone) {
  phone = phone.trim();

  if (phone.startsWith('+212')) return phone;

  if (phone.startsWith('0')) {
    return '+212${phone.substring(1)}';
  }

  return '+212$phone';
}

