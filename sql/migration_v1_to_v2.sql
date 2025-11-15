-- Schema migration from v1 -> v2 (introduces folders)
pragma foreign_keys = on;

-- 1. Create folders table to group feeds.
create table if not exists folders (
    id integer primary key autoincrement,
    name text not null,
    created_at datetime not null
);

create index if not exists idx_folders_name on folders(name);

-- 2. Add folder reference to feeds.
alter table feeds
    add column folder_id integer references folders(id) on delete set null;

create index if not exists idx_feeds_folder_id on feeds(folder_id);

-- Removing a folder should delete every feed and its items manually/in-app.
-- Feed deletions will continue to remove their feed_items explicitly.
