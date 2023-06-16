import { BadRequest, GatewayTimeout, NotFound } from 'http-errors';
import { getOrganizationInfo } from '../connectors/api-sirene';
import notificationMessages from '../notification-messages';
import { NextFunction, Request, Response } from 'express';
import { z, ZodError } from 'zod';
import {
  idSchema,
  optionalBooleanSchema,
  siretSchema,
} from '../services/custom-zod-schemas';
import { InseeNotFoundError, InseeTimeoutError } from '../errors';
import { sendModerationProcessedEmail } from '../managers/moderation';
import { markDomainAsVerified } from '../managers/organization/main';
import { forceJoinOrganization } from '../managers/organization/join';
import { notifyAllMembers } from '../managers/organization/authentication-by-peers';

export const getOrganizationInfoController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const schema = z.object({
      query: z.object({
        siret: siretSchema(),
      }),
    });

    const {
      query: { siret },
    } = await schema.parseAsync({
      query: req.query,
    });

    const organizationInfo = await getOrganizationInfo(siret);

    return res.json({ organizationInfo });
  } catch (e) {
    if (e instanceof InseeNotFoundError) {
      return next(new NotFound());
    }

    if (e instanceof ZodError) {
      return next(
        new BadRequest(notificationMessages['invalid_siret'].description)
      );
    }

    if (e instanceof InseeTimeoutError) {
      return next(
        new GatewayTimeout(notificationMessages['insee_timeout'].description)
      );
    }

    next(e);
  }
};

export const postForceJoinOrganizationController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const schema = z.object({
      query: z.object({
        organization_id: idSchema(),
        user_id: idSchema(),
        is_external: optionalBooleanSchema(),
      }),
    });

    const {
      query: { organization_id, user_id, is_external },
    } = await schema.parseAsync({
      query: req.query,
    });

    const userOrganizationLink = await forceJoinOrganization({
      organization_id,
      user_id,
      is_external,
    });

    await notifyAllMembers(userOrganizationLink);

    return res.json({});
  } catch (e) {
    console.error(e);
    if (e instanceof ZodError) {
      return next(new BadRequest());
    }

    next(e);
  }
};

export const postSendModerationProcessedEmail = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const schema = z.object({
      query: z.object({
        organization_id: idSchema(),
        user_id: idSchema(),
      }),
    });

    const {
      query: { organization_id, user_id },
    } = await schema.parseAsync({
      query: req.query,
    });

    await sendModerationProcessedEmail({ organization_id, user_id });

    return res.json({});
  } catch (e) {
    console.error(e);
    if (e instanceof ZodError) {
      return next(new BadRequest());
    }

    next(e);
  }
};

export const postMarkDomainAsVerified = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const schema = z.object({
      query: z.object({
        organization_id: idSchema(),
        domain: z.string().min(1),
      }),
    });

    const {
      query: { organization_id, domain },
    } = await schema.parseAsync({
      query: req.query,
    });

    await markDomainAsVerified({
      organization_id,
      domain,
      verification_type: 'verified_email_domain',
    });

    return res.json({});
  } catch (e) {
    console.error(e);
    if (e instanceof ZodError) {
      return next(new BadRequest());
    }

    next(e);
  }
};
