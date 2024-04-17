enum GalExceptionType {
  accessDenied,
  notEnoughSpace,
  notSupportedFormat,
  unexpected;

  String get message => switch (this) {
        accessDenied => 'You do not have permission to access the gallery app.',
        notEnoughSpace => 'Not enough space for storage.',
        notSupportedFormat => 'Unsupported file formats.',
        unexpected => 'An unexpected error has occurred.',
      };
}

const iconPng = 'assets/images/icon.png';

const googlePng = 'assets/images/google.png';

const personPng = 'assets/images/person.png';

// const fonFam = "seguiemj";
