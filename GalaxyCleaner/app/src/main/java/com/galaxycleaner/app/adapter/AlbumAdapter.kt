package com.galaxycleaner.app.adapter

import android.net.Uri
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.galaxycleaner.app.R
import com.galaxycleaner.app.databinding.ItemAlbumBinding
import com.galaxycleaner.app.model.Album

class AlbumAdapter(
    private val onToggleVisibility: (Album) -> Unit,
    private val onSelectionChanged: (Album, Boolean) -> Unit
) : ListAdapter<Album, AlbumAdapter.AlbumViewHolder>(DiffCallback()) {

    private val selectedItems = mutableSetOf<String>()
    var selectionMode = false
        set(value) {
            field = value
            if (!value) selectedItems.clear()
            notifyDataSetChanged()
        }

    fun getSelectedPaths(): List<String> = selectedItems.toList()

    fun selectAll() {
        currentList.forEach { selectedItems.add(it.path) }
        notifyDataSetChanged()
    }

    inner class AlbumViewHolder(private val binding: ItemAlbumBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(album: Album) {
            val isSelected = selectedItems.contains(album.path)

            binding.apply {
                tvAlbumName.text = album.name
                tvPhotoCount.text = root.context.getString(
                    R.string.album_photo_count, album.photoCount
                )

                // Cover image
                if (album.coverUri != null) {
                    ivAlbumCover.setImageURI(Uri.parse(album.coverUri))
                } else {
                    ivAlbumCover.setImageResource(
                        if (album.isHidden) R.drawable.ic_hidden_album
                        else R.drawable.ic_album_placeholder
                    )
                }

                // Hidden badge
                ivHiddenBadge.visibility = if (album.isHidden)
                    android.view.View.VISIBLE else android.view.View.GONE

                // Toggle switch (visible only in normal mode)
                switchVisibility.visibility = if (selectionMode)
                    android.view.View.GONE else android.view.View.VISIBLE
                switchVisibility.isChecked = !album.isHidden
                switchVisibility.setOnClickListener { onToggleVisibility(album) }

                // Checkbox (visible only in selection mode)
                checkboxSelect.visibility = if (selectionMode)
                    android.view.View.VISIBLE else android.view.View.GONE
                checkboxSelect.isChecked = isSelected
                checkboxSelect.setOnClickListener {
                    val nowSelected = checkboxSelect.isChecked
                    if (nowSelected) selectedItems.add(album.path)
                    else selectedItems.remove(album.path)
                    onSelectionChanged(album, nowSelected)
                }

                // Selection highlight
                root.isActivated = isSelected
                root.setOnClickListener {
                    if (selectionMode) {
                        val nowSelected = !selectedItems.contains(album.path)
                        if (nowSelected) selectedItems.add(album.path)
                        else selectedItems.remove(album.path)
                        checkboxSelect.isChecked = nowSelected
                        root.isActivated = nowSelected
                        onSelectionChanged(album, nowSelected)
                    }
                }
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AlbumViewHolder {
        val binding = ItemAlbumBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return AlbumViewHolder(binding)
    }

    override fun onBindViewHolder(holder: AlbumViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class DiffCallback : DiffUtil.ItemCallback<Album>() {
        override fun areItemsTheSame(oldItem: Album, newItem: Album) =
            oldItem.path == newItem.path

        override fun areContentsTheSame(oldItem: Album, newItem: Album) =
            oldItem == newItem
    }
}
