import { AxiosError } from 'axios';

export class InvalidEmailError extends Error {
  constructor(public didYouMean: string) {
    super();
    this.didYouMean = didYouMean;
  }
}

export class InvalidSiretError extends Error {}

export class InseeTimeoutError extends Error {}

export class InseeNotFoundError extends Error {}

export class InseeNotActiveError extends Error {}

export class UserNotFoundError extends Error {}

export class NotFoundError extends Error {}

export class UnableToAutoJoinOrganizationError extends Error {}

export class UserInOrganizationAlreadyError extends Error {}

export class UserAlreadyAskedToJoinOrganizationError extends Error {}

export class UserAlreadyAskedForSponsorshipError extends Error {
  constructor(public organization_id: number) {
    super();
    this.organization_id = organization_id;
  }
}

export class InvalidCredentialsError extends Error {}

export class EmailUnavailableError extends Error {}

export class WeakPasswordError extends Error {}

export class EmailVerifiedAlreadyError extends Error {}

export class InvalidTokenError extends Error {}

export class InvalidMagicLinkError extends Error {}

export class ApiAnnuaireNotFoundError extends Error {}

export class ApiAnnuaireTooManyResultsError extends Error {}

export class ApiAnnuaireInvalidEmailError extends Error {}

export class ApiAnnuaireTimeoutError extends Error {}

export class SendInBlueApiError extends Error {
  constructor(error: AxiosError<{ message: string; code: string }>) {
    if (error.response?.data?.code && error.response?.data?.message) {
      super(error.response?.data?.message);
      this.name = `SendInBlueApiError ${error.response?.data?.code}`;
    } else {
      super();
    }
  }
}
