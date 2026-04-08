package com.galaxycleaner.app.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.galaxycleaner.app.R
import com.galaxycleaner.app.databinding.ItemMacroBinding
import com.galaxycleaner.app.model.MacroAction
import com.galaxycleaner.app.model.MacroPreset

class MacroAdapter(
    private val onRun: (MacroPreset) -> Unit,
    private val onDelete: (MacroPreset) -> Unit
) : ListAdapter<MacroPreset, MacroAdapter.MacroViewHolder>(DiffCallback()) {

    inner class MacroViewHolder(private val binding: ItemMacroBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(preset: MacroPreset) {
            binding.apply {
                tvMacroName.text = preset.name
                tvMacroAlbumCount.text = root.context.getString(
                    R.string.macro_album_count, preset.albumPaths.size
                )
                tvMacroAction.text = when (preset.action) {
                    MacroAction.HIDE -> root.context.getString(R.string.action_hide)
                    MacroAction.SHOW -> root.context.getString(R.string.action_show)
                }
                ivMacroIcon.setImageResource(
                    if (preset.action == MacroAction.HIDE) R.drawable.ic_hide
                    else R.drawable.ic_show
                )
                btnRunMacro.setOnClickListener { onRun(preset) }
                btnDeleteMacro.setOnClickListener { onDelete(preset) }
            }
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MacroViewHolder {
        val binding = ItemMacroBinding.inflate(
            LayoutInflater.from(parent.context), parent, false
        )
        return MacroViewHolder(binding)
    }

    override fun onBindViewHolder(holder: MacroViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    class DiffCallback : DiffUtil.ItemCallback<MacroPreset>() {
        override fun areItemsTheSame(oldItem: MacroPreset, newItem: MacroPreset) =
            oldItem.id == newItem.id

        override fun areContentsTheSame(oldItem: MacroPreset, newItem: MacroPreset) =
            oldItem == newItem
    }
}
