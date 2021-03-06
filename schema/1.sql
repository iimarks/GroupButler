--
-- Types
--

-- CREATE TYPE chat_type AS ENUM ('group', 'supergroup', 'channel'); -- private chats live under the "user" table
-- CREATE TYPE chat_user_status AS ENUM ('creator', 'administrator', 'member', 'restricted', 'left', 'kicked');

--
-- Tables
--

CREATE TABLE "user" (
    id integer NOT NULL,
    is_bot boolean NOT NULL,
    first_name text NOT NULL,

    last_name text,
    username text,
    language_code varchar(35), -- BCP47/RFC5646 section 4.4.1 recommended maximum IETF tag length
    photo jsonb,

    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,

    CONSTRAINT user_pkey PRIMARY KEY (id)
);

-- CREATE TABLE "chat" (
--     id bigint NOT NULL,
--     type chat_type NOT NULL,
--     title text NOT NULL, -- Only private chats don't have titles, and we already store private info under "user"

--     username text, -- Supergroups and channels only
--     all_members_are_administrators boolean, -- Normal groups only
--     photo jsonb,
--     description text, -- Supergroups and channels only
--     invite_link text, -- Supergroups and channels only
--     pinned_message jsonb, -- Supergroups and channels only
--     sticker_set_name text, -- Supergroups only
--     can_set_sticker_set bool, -- Supergroups only

--     created_at timestamptz DEFAULT now() NOT NULL,
--     updated_at timestamptz DEFAULT now() NOT NULL,

--     CONSTRAINT chat_pkey PRIMARY KEY (id)
-- );

-- CREATE TABLE "chat_user" (
--     chat_id bigint NOT NULL REFERENCES "chat"(id),
--     user_id integer NOT NULL REFERENCES "user"(id),
--     status chat_user_status NOT NULL,

--     created_at timestamptz DEFAULT now() NOT NULL,
--     updated_at timestamptz DEFAULT now() NOT NULL,

--     CONSTRAINT chat_user_pkey PRIMARY KEY (chat_id, user_id)
-- );

-- CREATE TABLE "chat_user_admin" (
--     chat_id bigint NOT NULL REFERENCES "chat"(id),
--     user_id integer NOT NULL REFERENCES "user"(id),

--     can_be_edited boolean DEFAULT false NOT NULL,
--     can_change_info boolean DEFAULT false NOT NULL,
--     can_delete_messages boolean DEFAULT false NOT NULL,
--     can_invite_users boolean DEFAULT false NOT NULL,
--     can_restrict_members boolean DEFAULT false NOT NULL,
--     can_pin_messages boolean DEFAULT false NOT NULL,
--     can_promote_members boolean DEFAULT false NOT NULL,
--     can_post_messages boolean DEFAULT false NOT NULL, -- Channels only
--     can_edit_messages boolean DEFAULT false NOT NULL, -- Channels only

--     created_at timestamptz DEFAULT now() NOT NULL,
--     updated_at timestamptz DEFAULT now() NOT NULL,

--     CONSTRAINT chat_user_admin_pkey PRIMARY KEY (chat_id, user_id)
-- );

-- CREATE TABLE "chat_user_restricted" (
--     chat_id bigint NOT NULL REFERENCES "chat"(id),
--     user_id integer NOT NULL REFERENCES "user"(id),

--     until_date timestamptz, -- Date when restrictions will be lifted for this user, if ever
--     can_send_messages boolean DEFAULT true NOT NULL,
--     can_send_media_messages boolean DEFAULT true NOT NULL, -- implies can_send_messages
--     can_send_other_messages boolean DEFAULT true NOT NULL, -- implies can_send_media_messages
--     can_add_web_page_previews boolean DEFAULT true NOT NULL -- implies can_send_media_messages

--     created_at timestamptz DEFAULT now() NOT NULL,
--     updated_at timestamptz DEFAULT now() NOT NULL,

--     CONSTRAINT chat_user_restricted_pkey PRIMARY KEY (chat_id, user_id)
-- );

--
-- Triggers
--

CREATE OR REPLACE FUNCTION trigger_set_updated_at()
    RETURNS TRIGGER AS $$
    BEGIN
        NEW.updated_at = now();
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON "user"
    FOR EACH ROW
    EXECUTE PROCEDURE trigger_set_updated_at();

-- CREATE TRIGGER set_updated_at
--     BEFORE UPDATE ON "chat"
--     FOR EACH ROW
--     EXECUTE PROCEDURE trigger_set_updated_at();

-- CREATE TRIGGER set_updated_at
--     BEFORE UPDATE ON "chat_user"
--     FOR EACH ROW
--     EXECUTE PROCEDURE trigger_set_updated_at();

--
-- Foreign Keys
--

-- ALTER TABLE chat_user
--     ADD CONSTRAINT chat_user_chat_id_fkey FOREIGN KEY (chat_id)
--     REFERENCES "chat"(id) ON UPDATE CASCADE ON DELETE CASCADE;

-- ALTER TABLE chat_user
--     ADD CONSTRAINT chat_user_user_id_fkey FOREIGN KEY (user_id)
--     REFERENCES "user"(id) ON UPDATE CASCADE ON DELETE CASCADE;

--
-- Indexes
--

CREATE UNIQUE INDEX user_username_lower_idx ON "user" (lower(username));
